use axum::{
    response::Json,
    routing::{get, post},
    Router,
};
use base64::{engine::general_purpose, Engine as _};
use serde::{Deserialize, Serialize};
use solana_sdk::{
    instruction::Instruction,
    pubkey::Pubkey,
    signature::{Keypair, Signature, Signer},
    system_instruction,
};
use spl_token::instruction as spl_instruction;
use std::str::FromStr;
use tower_http::cors::CorsLayer;
use tracing::info;

// Response types (Updated for Fellowship Assignment)
#[derive(Serialize)]
struct ApiResponse<T> {
    success: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    data: Option<T>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

impl<T> ApiResponse<T> {
    fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    fn error(message: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message),
        }
    }
}

// Fellowship Assignment Request/Response structures
#[derive(Serialize)]
struct KeypairResponse {
    pubkey: String,
    secret: String,
}

#[derive(Deserialize)]
struct CreateTokenRequest {
    #[serde(rename = "mintAuthority")]
    mint_authority: String,
    mint: String,
    decimals: u8,
}

#[derive(Deserialize)]
struct MintTokenRequest {
    mint: String,
    destination: String,
    authority: String,
    amount: u64,
}

#[derive(Deserialize)]
struct SignMessageRequest {
    message: String,
    secret: String,
}

#[derive(Serialize)]
struct SignMessageResponse {
    signature: String,
    public_key: String,
    message: String,
}

#[derive(Deserialize)]
struct VerifyMessageRequest {
    message: String,
    signature: String,
    pubkey: String,
}

#[derive(Serialize)]
struct VerifyMessageResponse {
    valid: bool,
    message: String,
    pubkey: String,
}

#[derive(Deserialize)]
struct SendSolRequest {
    from: String,
    to: String,
    lamports: u64,
}

#[derive(Deserialize)]
struct SendTokenRequest {
    destination: String,
    mint: String,
    owner: String,
    amount: u64,
}

#[derive(Serialize)]
struct InstructionResponse {
    program_id: String,
    accounts: Vec<AccountInfo>,
    instruction_data: String, // Base64 encoded
}

#[derive(Serialize)]
struct AccountInfo {
    pubkey: String,
    #[serde(rename = "isSigner")]
    is_signer: bool,
    #[serde(rename = "isWritable")]
    is_writable: bool,
}

#[derive(Serialize)]
struct SendSolResponse {
    program_id: String,
    accounts: Vec<String>, // Just pubkey strings for SOL transfer
    instruction_data: String,
}

// Utility functions
fn encode_instruction(instruction: &Instruction) -> String {
    general_purpose::STANDARD.encode(bincode::serialize(instruction).unwrap())
}

fn keypair_to_response(keypair: &Keypair) -> KeypairResponse {
    KeypairResponse {
        pubkey: keypair.pubkey().to_string(),
        secret: bs58::encode(&keypair.to_bytes()).into_string(),
    }
}

// Route handlers
async fn health() -> Json<ApiResponse<&'static str>> {
    Json(ApiResponse::success("Solana HTTP server is running"))
}

async fn generate_keypair() -> Json<ApiResponse<KeypairResponse>> {
    let keypair = Keypair::new();
    Json(ApiResponse::success(keypair_to_response(&keypair)))
}

async fn sign_message(Json(req): Json<SignMessageRequest>) -> Json<ApiResponse<SignMessageResponse>> {
    match bs58::decode(&req.secret).into_vec() {
        Ok(bytes) => {
            if bytes.len() == 64 {
                match Keypair::try_from(bytes.as_slice()) {
                    Ok(keypair) => {
                        let message_bytes = req.message.as_bytes();
                        let signature = keypair.sign_message(message_bytes);
                        Json(ApiResponse::success(SignMessageResponse {
                            signature: general_purpose::STANDARD.encode(signature.as_ref()),
                            public_key: keypair.pubkey().to_string(),
                            message: req.message,
                        }))
                    }
                    Err(_) => Json(ApiResponse::error("Invalid secret key format".to_string())),
                }
            } else {
                Json(ApiResponse::error("Invalid secret key length".to_string()))
            }
        }
        Err(_) => Json(ApiResponse::error("Invalid base58 encoding for secret key".to_string())),
    }
}

async fn verify_message(Json(req): Json<VerifyMessageRequest>) -> Json<ApiResponse<VerifyMessageResponse>> {
    match (
        Pubkey::from_str(&req.pubkey),
        general_purpose::STANDARD.decode(&req.signature),
    ) {
        (Ok(pubkey), Ok(signature_bytes)) => {
            if signature_bytes.len() == 64 {
                let signature = Signature::from(
                    <[u8; 64]>::try_from(signature_bytes.as_slice()).unwrap()
                );
                let message_bytes = req.message.as_bytes();
                let valid = signature.verify(&pubkey.to_bytes(), message_bytes);
                Json(ApiResponse::success(VerifyMessageResponse { 
                    valid,
                    message: req.message,
                    pubkey: req.pubkey,
                }))
            } else {
                Json(ApiResponse::error("Invalid signature length".to_string()))
            }
        }
        _ => Json(ApiResponse::error("Invalid public key or signature format".to_string())),
    }
}

async fn create_token(Json(req): Json<CreateTokenRequest>) -> Json<ApiResponse<InstructionResponse>> {
    match (
        Pubkey::from_str(&req.mint_authority),
        Pubkey::from_str(&req.mint),
    ) {
        (Ok(mint_authority), Ok(mint_pubkey)) => {
            let instruction = spl_instruction::initialize_mint(
                &spl_token::id(),
                &mint_pubkey,
                &mint_authority,
                None,
                req.decimals,
            ).unwrap();

            let accounts = instruction.accounts.iter().map(|acc| AccountInfo {
                pubkey: acc.pubkey.to_string(),
                is_signer: acc.is_signer,
                is_writable: acc.is_writable,
            }).collect();

            Json(ApiResponse::success(InstructionResponse {
                program_id: instruction.program_id.to_string(),
                accounts,
                instruction_data: encode_instruction(&instruction),
            }))
        }
        _ => Json(ApiResponse::error("Invalid pubkey format".to_string())),
    }
}

async fn mint_token(Json(req): Json<MintTokenRequest>) -> Json<ApiResponse<InstructionResponse>> {
    match (
        Pubkey::from_str(&req.mint),
        Pubkey::from_str(&req.destination),
        Pubkey::from_str(&req.authority),
    ) {
        (Ok(mint), Ok(destination), Ok(authority)) => {
            let instruction = spl_instruction::mint_to(
                &spl_token::id(),
                &mint,
                &destination,
                &authority,
                &[],
                req.amount,
            ).unwrap();

            let accounts = instruction.accounts.iter().map(|acc| AccountInfo {
                pubkey: acc.pubkey.to_string(),
                is_signer: acc.is_signer,
                is_writable: acc.is_writable,
            }).collect();

            Json(ApiResponse::success(InstructionResponse {
                program_id: instruction.program_id.to_string(),
                accounts,
                instruction_data: encode_instruction(&instruction),
            }))
        }
        _ => Json(ApiResponse::error("Invalid pubkey format".to_string())),
    }
}

async fn send_sol(Json(req): Json<SendSolRequest>) -> Json<ApiResponse<SendSolResponse>> {
    match (
        Pubkey::from_str(&req.from),
        Pubkey::from_str(&req.to),
    ) {
        (Ok(from), Ok(to)) => {
            // Validate that lamports amount is reasonable
            if req.lamports == 0 {
                return Json(ApiResponse::error("Amount must be greater than 0".to_string()));
            }
            
            let instruction = system_instruction::transfer(&from, &to, req.lamports);
            
            Json(ApiResponse::success(SendSolResponse {
                program_id: instruction.program_id.to_string(),
                accounts: instruction.accounts.iter().map(|acc| acc.pubkey.to_string()).collect(),
                instruction_data: encode_instruction(&instruction),
            }))
        }
        _ => Json(ApiResponse::error("Invalid pubkey format".to_string())),
    }
}

async fn send_token(Json(req): Json<SendTokenRequest>) -> Json<ApiResponse<InstructionResponse>> {
    match (
        Pubkey::from_str(&req.destination),
        Pubkey::from_str(&req.mint),
        Pubkey::from_str(&req.owner),
    ) {
        (Ok(destination), Ok(mint), Ok(owner)) => {
            // Get associated token accounts
            let source = spl_associated_token_account::get_associated_token_address(&owner, &mint);
            
            let instruction = spl_instruction::transfer(
                &spl_token::id(),
                &source,
                &destination,
                &owner,
                &[],
                req.amount,
            ).unwrap();

            let accounts = instruction.accounts.iter().map(|acc| AccountInfo {
                pubkey: acc.pubkey.to_string(),
                is_signer: acc.is_signer,
                is_writable: acc.is_writable,
            }).collect();

            Json(ApiResponse::success(InstructionResponse {
                program_id: instruction.program_id.to_string(),
                accounts,
                instruction_data: encode_instruction(&instruction),
            }))
        }
        _ => Json(ApiResponse::error("Invalid pubkey format".to_string())),
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Build the router with Fellowship Assignment endpoints
    let app = Router::new()
        .route("/health", get(health))
        .route("/keypair", post(generate_keypair))
        .route("/token/create", post(create_token))
        .route("/token/mint", post(mint_token))
        .route("/message/sign", post(sign_message))
        .route("/message/verify", post(verify_message))
        .route("/send/sol", post(send_sol))
        .route("/send/token", post(send_token))
        .layer(CorsLayer::permissive());

    let port = std::env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    let addr = format!("0.0.0.0:{}", port);
    
    info!("🚀 Starting Solana Fellowship Assignment HTTP Server on {}", addr);
    info!("📋 Available endpoints:");
    info!("   POST /keypair - Generate keypair");
    info!("   POST /token/create - Create token");
    info!("   POST /token/mint - Mint token");
    info!("   POST /message/sign - Sign message");
    info!("   POST /message/verify - Verify message");
    info!("   POST /send/sol - Send SOL");
    info!("   POST /send/token - Send token");
    
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}