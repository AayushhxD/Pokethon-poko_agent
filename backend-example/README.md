# Backend README

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Add your API keys to `.env`

4. Run locally:
```bash
npm run dev
```

## Deploy to Vercel

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Deploy:
```bash
vercel deploy
```

3. Add environment variables in Vercel dashboard

4. Update Flutter app with your API URL in `lib/utils/constants.dart`

## Endpoints

- `GET /api/health` - Health check
- `POST /api/chat` - AI chat
- `POST /api/battle` - Battle simulation
- `POST /api/evolve` - Evolution data
- `POST /api/mint` - Mint agent

## Testing

```bash
curl http://localhost:3000/api/health
```

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "agentName": "Pikachu",
    "agentType": "Electric",
    "message": "Hello!",
    "personality": "Friendly"
  }'
```
