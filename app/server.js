const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// DB Connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'taskuser',
  password: 'Task@1234',
  database: 'taskdb'
});

db.connect((err) => {
  if (err) {
    console.error('DB Error:', err);
    return;
  }
  console.log('MySQL Connected!');

  // Table banao agar nahi hai
  db.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

// Routes
// Saari tasks lo
app.get('/tasks', (req, res) => {
  db.query('SELECT * FROM tasks ORDER BY created_at DESC', 
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      res.json(results);
  });
});

// Nayi task add karo
app.post('/tasks', (req, res) => {
  const { title } = req.body;
  db.query('INSERT INTO tasks (title) VALUES (?)', 
    [title], (err, result) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ id: result.insertId, title });
  });
});

// Task delete karo
app.delete('/tasks/:id', (req, res) => {
  db.query('DELETE FROM tasks WHERE id = ?', 
    [req.params.id], (err) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ message: 'Deleted!' });
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
