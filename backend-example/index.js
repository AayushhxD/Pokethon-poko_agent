// Example Node.js/Express Backend for PokéAgents
// Deploy this to Vercel, Render, or Railway

const express = require('express');
const cors = require('cors');
const { Configuration, OpenAIApi } = require('openai');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const openai = new OpenAIApi(
  new Configuration({
    apiKey: process.env.OPENAI_API_KEY,
  })
);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'PokéAgents API is running' });
});

// Chat with agent
app.post('/api/chat', async (req, res) => {
  try {
    const { agentName, agentType, message, personality } = req.body;

    const systemPrompt = `You are ${agentName}, a ${agentType}-type PokéAgent. 
Your personality is ${personality}. 
Respond playfully like a Pokémon would, using sound effects and enthusiasm.
Keep responses short (1-2 sentences).
Example: "Pika-pika! ⚡ I'm so excited to train with you today!"`;

    const completion = await openai.createChatCompletion({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: message },
      ],
      max_tokens: 100,
      temperature: 0.9,
    });

    const response = completion.data.choices[0].message.content;
    res.json({ response });
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Failed to generate response' });
  }
});

// Battle simulation
app.post('/api/battle', async (req, res) => {
  try {
    const { agent1, agent2 } = req.body;

    const battlePrompt = `Simulate a short Pokémon-style battle between:
Agent 1: ${agent1.name} (${agent1.type}-type, Level ${agent1.stats.attack})
Agent 2: ${agent2.name} (${agent2.type}-type, Level ${agent2.stats.attack})

Create a 3-turn battle narrative with:
1. Opening move by Agent 1
2. Counter move by Agent 2
3. Final decisive move
4. Declare the winner

Format as JSON with:
{
  "winner": "agent name",
  "narrative": ["turn 1", "turn 2", "turn 3", "result"],
  "turns": 3
}`;

    const completion = await openai.createChatCompletion({
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: battlePrompt }],
      max_tokens: 300,
    });

    const result = JSON.parse(completion.data.choices[0].message.content);
    res.json(result);
  } catch (error) {
    console.error('Battle error:', error);
    
    // Fallback battle logic
    const { agent1, agent2 } = req.body;
    const winner = Math.random() > 0.5 ? agent1.name : agent2.name;
    
    res.json({
      winner,
      narrative: [
        `${agent1.name} uses Thunder Strike! ⚡`,
        `${agent2.name} counters with Water Blast! 💧`,
        `${winner} lands the final blow!`,
        `${winner} wins the battle! 🏆`,
      ],
      turns: 3,
    });
  }
});

// Evolution data
app.post('/api/evolve', async (req, res) => {
  try {
    const { agentName, agentType, newStage } = req.body;

    const evolvePrompt = `Create an evolution for this PokéAgent:
Name: ${agentName}
Type: ${agentType}
New Stage: ${newStage}

Generate:
1. A cool evolved name (e.g., Pikachu → Raichu)
2. Brief description of new appearance
3. New ability name

Format as JSON:
{
  "newName": "evolved name",
  "description": "appearance description",
  "ability": "special ability name",
  "statBoost": {
    "hp": 20,
    "attack": 15,
    "defense": 15,
    "speed": 10,
    "special": 20
  }
}`;

    const completion = await openai.createChatCompletion({
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: evolvePrompt }],
      max_tokens: 200,
    });

    const result = JSON.parse(completion.data.choices[0].message.content);
    res.json(result);
  } catch (error) {
    console.error('Evolution error:', error);
    
    // Fallback evolution
    const { agentName, newStage } = req.body;
    const suffixes = ['X', 'Prime', 'Max', 'Ultra'];
    
    res.json({
      newName: `${agentName}-${suffixes[newStage - 2] || 'X'}`,
      description: `${agentName} has evolved into a more powerful form!`,
      ability: 'Mega Blast',
      statBoost: {
        hp: 20,
        attack: 15,
        defense: 15,
        speed: 10,
        special: 20,
      },
    });
  }
});

// Mint agent (generates AI image URL)
app.post('/api/mint', async (req, res) => {
  try {
    const { name, type, walletAddress } = req.body;

    // In production, use DALL-E or Stable Diffusion
    // const image = await openai.createImage({
    //   prompt: `A cute ${type}-type pokemon creature named ${name}, digital art`,
    //   n: 1,
    //   size: "512x512",
    // });

    // For now, return placeholder
    res.json({
      success: true,
      imageUrl: `https://via.placeholder.com/512?text=${type}-${name}`,
      metadataUri: 'ipfs://QmExample...',
      tokenId: Date.now().toString(),
    });
  } catch (error) {
    console.error('Mint error:', error);
    res.status(500).json({ error: 'Failed to mint agent' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 PokéAgents API running on port ${PORT}`);
});

module.exports = app; // For Vercel serverless
