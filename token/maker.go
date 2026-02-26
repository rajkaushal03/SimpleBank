package token

import "time"

// Maker is an interface of managing Tokens
type Maker interface {
	// CreateToken will create a new token for a specific username and duration
	CreateToken(username string, duration time.Duration) (string, error)

	// Verifytoken will check if the token is valid or not
	Verifytoken(token string) (*Payload, error)
}
