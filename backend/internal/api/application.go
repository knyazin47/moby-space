package api

type Result[T any] struct {
	Value  T
	Status int
}
type DomainError struct {
	Status int
	Code   string
}

func (e *DomainError) Error() string { return e.Code }
func domainError(status int, code string) *DomainError {
	return &DomainError{Status: status, Code: code}
}

type ChildInput = childInput
type MoneyInput = moneyInput
type SuccessAck struct {
	OK bool `json:"ok"`
}
type SessionGrant struct {
	Token     string `json:"token"`
	Actor     Actor  `json:"actor"`
	ExpiresAt int64  `json:"expiresAt"`
}
type PairingCreated struct {
	ID            string `json:"id"`
	Code          string `json:"code"`
	RequestSecret string `json:"requestSecret"`
	ExpiresAt     int64  `json:"expiresAt"`
	Status        string `json:"status"`
}
type PairingResult struct {
	ID      string `json:"id,omitempty"`
	Status  string `json:"status"`
	ChildID string `json:"childId,omitempty"`
}
type PairingPoll struct {
	Status  string        `json:"status"`
	Session *SessionGrant `json:"session,omitempty"`
}
type SessionSummary struct {
	ID         string `json:"id"`
	Role       string `json:"role"`
	ChildID    string `json:"childId,omitempty"`
	DeviceName string `json:"deviceName"`
	ExpiresAt  int64  `json:"expiresAt"`
	Revoked    bool   `json:"revoked"`
}
type LoginInput struct {
	BootstrapSecret string `json:"bootstrapSecret"`
	DeviceName      string `json:"deviceName"`
}

type ChildPatch struct {
	DisplayName *string `json:"displayName"`
	LegalName   *string `json:"legalName"`
	DateOfBirth *string `json:"dateOfBirth"`
	CardStatus  *string `json:"cardStatus"`
}

type VerificationInput struct {
	Outcome string `json:"outcome"`
}

type ProductInput struct {
	AgreementVersion string `json:"agreementVersion"`
	SignerConsent    bool   `json:"signerConsent"`
}

type DecisionInput struct {
	Approve *bool `json:"approve"`
}

type CreatePairInput struct {
	DeviceName string `json:"deviceName"`
}

type ConsumePairInput struct {
	Code    string `json:"code"`
	ChildID string `json:"childId"`
}

type PairSecretInput struct {
	RequestSecret string `json:"requestSecret"`
}
