const PAGE_VIEWS_KEY = 'wdss:stats:page_views';
const LISTEN_STARTS_KEY = 'wdss:stats:listen_starts';

function parseBody(body) {
  if (!body) return {};
  if (typeof body === 'string') {
    try { return JSON.parse(body); } catch (_) { return {}; }
  }
  return body;
}

function getRedisConfig() {
  const url = process.env.WDSS_REDIS_KV_REST_API_URL;
  const token = process.env.WDSS_REDIS_KV_REST_API_TOKEN;
  if (!url || !token) throw new Error('Redis is not configured');
  return { url: url.replace(/\/$/, ''), token };
}

async function redisCommand(config, ...command) {
  const path = command.map(value => encodeURIComponent(String(value))).join('/');
  const response = await fetch(`${config.url}/${path}`, {
    headers: { Authorization: `Bearer ${config.token}` }
  });
  const data = await response.json();
  if (!response.ok || data.error) throw new Error(data.error || 'Redis request failed');
  return data.result;
}

module.exports = async (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const event = parseBody(req.body).event;
  const key = event === 'page_view' ? PAGE_VIEWS_KEY : event === 'listen_start' ? LISTEN_STARTS_KEY : null;
  if (!key) return res.status(400).json({ error: 'Unknown event' });

  try {
    const config = getRedisConfig();
    await redisCommand(config, 'incr', key);
    const [pageViews, listenStarts] = await redisCommand(config, 'mget', PAGE_VIEWS_KEY, LISTEN_STARTS_KEY);
    return res.status(200).json({ pageViews: Number(pageViews || 0), listenStarts: Number(listenStarts || 0) });
  } catch (error) {
    console.error('Counter error:', error.message);
    return res.status(503).json({ error: 'Counter unavailable' });
  }
};
