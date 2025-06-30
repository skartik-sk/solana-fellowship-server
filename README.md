# Solana HTTP Server

A Rust-based HTTP server that exposes Solana-related endpoints for keypair generation, SPL token operations, message signing/verification, and transaction instruction construction.

## Features

- 🔑 Keypair generation and management
- 📝 Message signing and verification
- 🪙 SPL token account creation and transfers
- 💰 SOL transfer instructions
- 🔗 Associated token account operations
- 🌐 RESTful API with JSON responses

## API Endpoints

### Health Check
- `GET /health` - Check if the server is running

### Keypair Operations
- `POST /keypair/generate` - Generate a new Solana keypair
- `GET /keypair/public/:secret_key` - Get public key from secret key

### Message Operations
- `POST /message/sign` - Sign a message with a secret key
- `POST /message/verify` - Verify a signed message

### Token Operations
- `POST /token/account/create` - Create associated token account instruction
- `GET /token/account/address/:owner/:mint` - Get associated token account address
- `POST /token/transfer` - Create SPL token transfer instruction

### SOL Operations
- `POST /sol/transfer` - Create SOL transfer instruction

## Quick Start

1. **Install dependencies:**
   ```bash
   cargo build
   ```

2. **Run the server:**
   ```bash
   cargo run
   ```

3. **Server will start on port 3000 (or PORT environment variable)**

## API Examples

### Generate Keypair
```bash
curl -X POST http://localhost:3000/keypair/generate
```

Response:
```json
{
  "success": true,
  "data": {
    "public_key": "9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM",
    "secret_key": "base58_encoded_secret_key"
  },
  "error": null
}
```

### Sign Message
```bash
curl -X POST http://localhost:3000/message/sign \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Solana!",
    "secret_key": "your_base58_secret_key"
  }'
```

### Create Token Transfer Instruction
```bash
curl -X POST http://localhost:3000/token/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "source": "source_token_account_pubkey",
    "destination": "destination_token_account_pubkey", 
    "owner": "owner_pubkey",
    "amount": 1000000
  }'
```

### Create SOL Transfer Instruction
```bash
curl -X POST http://localhost:3000/sol/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "from_pubkey": "sender_pubkey",
    "to_pubkey": "recipient_pubkey",
    "lamports": 1000000000
  }'
```

## Response Format

All endpoints return responses in the following format:

```json
{
  "success": boolean,
  "data": any | null,
  "error": string | null
}
```

## Environment Variables

- `PORT` - Server port (default: 3000)

## Dependencies

- **axum** - Web framework
- **serde** - Serialization
- **solana-sdk** - Solana blockchain SDK
- **spl-token** - SPL token program
- **tower-http** - HTTP middleware
- **tokio** - Async runtime

## Development

```bash
# Run in development mode
cargo run

# Run tests
cargo test

# Format code
cargo fmt

# Check for errors
cargo check
```

## Security Notes

⚠️ **Important**: This server is designed for development and testing purposes. In production:

- Never expose secret keys in API responses
- Implement proper authentication and authorization
- Use HTTPS for all communications
- Validate all inputs thoroughly
- Consider rate limiting and other security measures

## License

MIT License
