# Go conventions

## General

1. Prefer `fmt.Sprintf` over concatenating multiple strings with `+` when it makes the result easier to read.

Keep the string's structure in the format string and pass variable values as arguments.

Do it like this:

```go
message := fmt.Sprintf("User %s created order %s", userName, orderID)
```

Not like this:

```go
message := "User " + userName + " created order " + orderID
```

For SQL query values, use placeholders and pass values separately instead of using concatenation or `fmt.Sprintf`. This prevents SQL injection. The following example uses PostgreSQL placeholders.

Do it like this:

```go
query := `
    SELECT id
    FROM users
    WHERE name = $1 AND status = $2
`
err := db.QueryRowContext(ctx, query, userName, status).Scan(&userID)
```

Not like this:

```go
query := "SELECT id FROM users WHERE name = '" + userName + "' AND status = '" + status + "'"
err := db.QueryRowContext(ctx, query).Scan(&userID)
```

2. Define SQL queries in a separate variable and put each SQL clause on its own line instead of embedding a compact query in the database call.

Use the placeholder syntax supported by the database driver. This example uses `?` placeholders.

Do it like this:

```go
query := `
    INSERT INTO chat_messages (id, conversation_id, role, content, created_at)
    VALUES (?, ?, 'assistant', ?, ?)
`
_, err := db.ExecContext(ctx, query, messageID, conversationID, content, createdAt)
```

Not like this:

```go
_, err := db.ExecContext(ctx, "INSERT INTO chat_messages (id,conversation_id,role,content,created_at) VALUES (?,?,'assistant',?,?)", messageID, conversationID, content, createdAt)
```
