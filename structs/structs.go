package structs

import "github.com/google/uuid"

type HTTPResponse struct {
	Status      int
	Application string
	UUID        uuid.UUID
	Data        string
}
