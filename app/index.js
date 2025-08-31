const http = require('http');
const url = require('url');
const sqlite3 = require('sqlite3').verbose();

// Initialize database
const db = new sqlite3.Database(':memory:');

// Create a sample table
db.serialize(() => {
  db.run(`CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    age INTEGER
  )`);
  
  // Insert sample data
  db.run(`INSERT INTO users (name, email, age) VALUES 
    ('John Doe', 'john@example.com', 30),
    ('Jane Smith', 'jane@example.com', 25),
    ('Bob Johnson', 'bob@example.com', 35),
    ('Alice Brown', 'alice@example.com', 28)
  `);
});

const server = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Parse URL and query parameters
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const queryParams = parsedUrl.query;

  console.log('Request URL:', req.url);
  console.log('Query parameters:', queryParams);

  if (req.method === 'GET' && pathname === '/query') {
    // Handle database query with concatenated SQL
    const table = queryParams.table || 'users';
    const column = queryParams.column || '*';
    const condition = queryParams.condition || '';
    
    // Build concatenated SQL query
    let sqlQuery = `SELECT ${column} FROM ${table}`;
    if (condition) {
      sqlQuery += ` WHERE ${condition}`;
    }
    
    console.log('Executing SQL query:', sqlQuery);
    
    // Execute the concatenated query
    db.all(sqlQuery, [], (err, rows) => {
      if (err) {
        console.error('Database error:', err);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
          error: 'Database error', 
          message: err.message,
          query: sqlQuery 
        }));
        return;
      }
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        query: sqlQuery,
        results: rows,
        count: rows.length
      }));
    });
  } else if (req.method === 'GET' && pathname === '/users') {
    // Simple endpoint to get all users
    const sqlQuery = `SELECT * FROM users`;
    
    db.all(sqlQuery, [], (err, rows) => {
      if (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Database error', message: err.message }));
        return;
      }
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        query: sqlQuery,
        users: rows
      }));
    });
  } else if (req.method === 'GET' && pathname === '/') {
    // Root endpoint with usage instructions
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>SQL Query Demo</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          .example { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
          code { background: #e0e0e0; padding: 2px 4px; border-radius: 3px; }
        </style>
      </head>
      <body>
        <h1>SQL Query Demo with URL Parameters</h1>
        <p>This demo shows how to use URL parameters to build concatenated SQL queries.</p>
        
        <h2>Available Endpoints:</h2>
        
        <div class="example">
          <h3>1. Get all users:</h3>
          <code>GET /users</code>
        </div>
        
        <div class="example">
          <h3>2. Custom query with parameters:</h3>
          <code>GET /query?table=users&column=name,email&condition=age>25</code>
        </div>
        
        <h2>Query Parameters:</h2>
        <ul>
          <li><strong>table</strong>: Table name (default: users)</li>
          <li><strong>column</strong>: Columns to select (default: *)</li>
          <li><strong>condition</strong>: WHERE condition (optional)</li>
        </ul>
        
        <h2>Example Queries:</h2>
        <div class="example">
          <p><strong>Get all users:</strong></p>
          <code>/query</code>
        </div>
        
        <div class="example">
          <p><strong>Get only names and emails:</strong></p>
          <code>/query?column=name,email</code>
        </div>
        
        <div class="example">
          <p><strong>Get users older than 25:</strong></p>
          <code>/query?condition=age>25</code>
        </div>
        
        <div class="example">
          <p><strong>Get names of users with age > 25:</strong></p>
          <code>/query?column=name&condition=age>25</code>
        </div>
        
        <div class="example">
          <p><strong>Get users with specific email:</strong></p>
          <code>/query?condition=email='john@example.com'</code>
        </div>
      </body>
      </html>
    `);
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Endpoint not found' }));
  }
});

server.listen(3000, () => {
  console.log('Server listening on port 3000');
  console.log('Available endpoints:');
  console.log('  GET / - Show usage instructions');
  console.log('  GET /users - Get all users');
  console.log('  GET /query?table=users&column=name,email&condition=age>25 - Custom query');
});
