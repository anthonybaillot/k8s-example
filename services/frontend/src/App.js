import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [status, setStatus] = useState('Loading...');

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
        const response = await fetch(`${backendUrl}/users`);
        
        if (response.ok) {
          const data = await response.json();
          setUsers(data.users);
          setStatus('Connected');
        } else {
          setStatus('Backend connection failed');
        }
      } catch (error) {
        setStatus('Backend connection failed');
        console.error('Error fetching users:', error);
      }
    };

    fetchUsers();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>K8s Example App</h1>
        <p>Status: {status}</p>
        
        <div className="users-section">
          <h2>Users</h2>
          {users.length > 0 ? (
            <ul>
              {users.map(user => (
                <li key={user.id}>
                  <strong>{user.name}</strong> - {user.email}
                  <br />
                  <small>Created: {new Date(user.created_at).toLocaleDateString()}</small>
                </li>
              ))}
            </ul>
          ) : (
            <p>No users found</p>
          )}
        </div>
      </header>
    </div>
  );
}

export default App;