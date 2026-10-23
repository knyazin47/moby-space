package api

// DemoMoneyConfig is the single source for the synthetic adult bootstrap grant.
// Existing child balances are opening balances and are never rewritten.
type DemoMoneyConfig struct {
	InitialAdultMinor int64 `json:"initialAdultMinor"`
}

var DefaultDemoMoney = DemoMoneyConfig{InitialAdultMinor: 100000}

const moneyCap int64 = 100000000

type Wallet struct {
	AvailableMinor int64  `json:"availableMinor"`
	ReservedMinor  int64  `json:"reservedMinor"`
	Currency       string `json:"currency"`
}
type Goal struct {
	ID                     string `json:"id"`
	ChildID                string `json:"childId"`
	Title                  string `json:"title"`
	TargetMinor            int64  `json:"targetMinor"`
	SavedMinor             int64  `json:"savedMinor"`
	MatchedMinor           int64  `json:"matchedMinor"`
	NetDepositsMinor       int64  `json:"netDepositsMinor"`
	MatchedBasisMinor      int64  `json:"matchedBasisMinor"`
	MatchingAvailableMinor int64  `json:"matchingAvailableMinor"`
	MatchingStatus         string `json:"matchingStatus"`
}
type FamilyTask struct {
	CancelReason    string `json:"cancelReason,omitempty"`
	ID              string `json:"id"`
	ChildID         string `json:"childId"`
	Title           string `json:"title"`
	RewardMinor     int64  `json:"rewardMinor"`
	Status          string `json:"status"`
	CancelRequested bool   `json:"cancelRequested"`
}
type Errand struct {
	CancelReason    string `json:"cancelReason,omitempty"`
	RewardReserved  bool   `json:"rewardReserved"`
	ExpenseRecorded bool   `json:"expenseRecorded"`
	ID              string `json:"id"`
	ChildID         string `json:"childId"`
	Title           string `json:"title"`
	BudgetMinor     int64  `json:"budgetMinor"`
	RewardMinor     int64  `json:"rewardMinor"`
	ActualMinor     int64  `json:"actualMinor"`
	ReturnedMinor   int64  `json:"returnedMinor"`
	Funding         string `json:"funding"`
	Status          string `json:"status"`
	ReturnConfirmed bool   `json:"returnConfirmed"`
	OwnMoneyConsent bool   `json:"ownMoneyConsent"`
	CancelRequested bool   `json:"cancelRequested"`
}
type Allowance struct {
	ID          string `json:"id"`
	ChildID     string `json:"childId"`
	Title       string `json:"title"`
	AmountMinor int64  `json:"amountMinor"`
	Frequency   string `json:"frequency"`
	Weekdays    []int  `json:"weekdays"`
	MonthDay    int    `json:"monthDay"`
	NextDate    string `json:"nextDate"`
	RetryLimit  int    `json:"retryLimit"`
	Active      bool   `json:"active"`
}
type Installment struct {
	RetryLimit      *int   `json:"retryLimit,omitempty"`
	ID              string `json:"id"`
	ChildID         string `json:"childId"`
	AllowanceID     string `json:"allowanceId"`
	DueDate         string `json:"dueDate"`
	AmountMinor     int64  `json:"amountMinor"`
	Status          string `json:"status"`
	Attempts        int    `json:"attempts"`
	LastAttemptDate string `json:"lastAttemptDate,omitempty"`
}
type SpaceSettings struct {
	MatchingEnabled  bool  `json:"matchingEnabled"`
	MatchingPercent  int64 `json:"matchingPercent"`
	MatchingCapMinor int64 `json:"matchingCapMinor"`
	Notifications    bool  `json:"notifications"`
	TasksEnabled     bool  `json:"tasksEnabled"`
	ErrandsEnabled   bool  `json:"errandsEnabled"`
	LearningEnabled  bool  `json:"learningEnabled"`
}

func defaultSpaceSettings() SpaceSettings {
	return SpaceSettings{Notifications: true, TasksEnabled: true, ErrandsEnabled: true, LearningEnabled: true}
}

type FamilyRequest struct {
	AmountMinor int64   `json:"amountMinor,omitempty"`
	ID          string  `json:"id"`
	ChildID     string  `json:"childId"`
	Kind        string  `json:"kind"`
	Title       string  `json:"title"`
	Policy      *Policy `json:"policy,omitempty"`
	Status      string  `json:"status"`
}
type Lesson struct {
	Question      string   `json:"question"`
	Options       []string `json:"options"`
	CorrectAnswer int      `json:"-"`
	ID            string   `json:"id"`
	Title         string   `json:"title"`
	Body          string   `json:"body"`
	Skill         string   `json:"skill"`
}

var lessonCatalogue = []Lesson{
	{ID: "needs-wants", Title: "Нужды и желания", Body: "Перед покупкой подумай: это необходимо сейчас или можно отложить?", Skill: "planning", Question: "Что лучше сделать перед необязательной покупкой?", Options: []string{"Сравнить её с важными расходами", "Купить сразу, не считая деньги"}, CorrectAnswer: 0},
	{ID: "saving-goal", Title: "Как копить на цель", Body: "Раздели стоимость цели на небольшие части. Деньги в цели хранятся отдельно от доступных для покупок.", Skill: "saving", Question: "Где хранится сумма, отложенная на цель?", Options: []string{"В общем доступном остатке", "Отдельно от денег для покупок"}, CorrectAnswer: 1},
	{ID: "safe-payment", Title: "Безопасная оплата", Body: "Не сообщай коды, пароли и данные карты. Если сомневаешься, обратись к взрослому.", Skill: "safety", Question: "Незнакомец просит код из сообщения. Что делать?", Options: []string{"Не сообщать код и обратиться к взрослому", "Продиктовать код"}, CorrectAnswer: 0},
	{ID: "budget", Title: "План расходов", Body: "Сравни доступные деньги и будущие траты. Оставь запас на необходимое.", Skill: "budgeting", Question: "Что нужно учесть в плане расходов?", Options: []string{"Только желаемые покупки", "Доступные деньги и будущие необходимые траты"}, CorrectAnswer: 1},
}

type LessonCompletion struct {
	ChildID     string `json:"childId"`
	LessonID    string `json:"lessonId"`
	CompletedAt int64  `json:"completedAt"`
}
type SpaceEntry struct {
	ID          string `json:"id"`
	ChildID     string `json:"childId,omitempty"`
	Kind        string `json:"kind"`
	AmountMinor int64  `json:"amountMinor"`
	At          int64  `json:"at"`
	EntityID    string `json:"entityId,omitempty"`
}
type WeeklyOverview struct {
	ChildID          string `json:"childId"`
	Since            string `json:"since"`
	IncomingMinor    int64  `json:"incomingMinor"`
	SpentMinor       int64  `json:"spentMinor"`
	SavedMinor       int64  `json:"savedMinor"`
	TasksCompleted   int    `json:"tasksCompleted"`
	LessonsCompleted int    `json:"lessonsCompleted"`
}
type SpaceCommandRecord struct {
	FingerprintVersion int    `json:"fingerprintVersion,omitempty"`
	Fingerprint        string `json:"fingerprint"`
}
type SpaceNotice struct {
	ID        string `json:"id"`
	ChildID   string `json:"childId"`
	Recipient string `json:"recipient"`
	Title     string `json:"title"`
	Body      string `json:"body"`
	Kind      string `json:"kind"`
	CreatedAt int64  `json:"createdAt"`
	Read      bool   `json:"read"`
	Mandatory bool   `json:"mandatory"`
}
type FamilySpaceState struct {
	Notices           map[string]*SpaceNotice       `json:"notices"`
	Wallet            Wallet                        `json:"wallet"`
	BootstrapRecorded bool                          `json:"bootstrapRecorded"`
	Goals             map[string]*Goal              `json:"goals"`
	Tasks             map[string]*FamilyTask        `json:"tasks"`
	Errands           map[string]*Errand            `json:"errands"`
	Allowances        map[string]*Allowance         `json:"allowances"`
	Installments      map[string]*Installment       `json:"installments"`
	Requests          map[string]*FamilyRequest     `json:"requests"`
	Settings          map[string]SpaceSettings      `json:"settings"`
	Learning          map[string]LessonCompletion   `json:"learning"`
	Entries           []SpaceEntry                  `json:"entries"`
	Commands          map[string]SpaceCommandRecord `json:"commands"`
}
type FamilyCapabilities struct {
	Synthetic               bool   `json:"synthetic"`
	Currency                string `json:"currency"`
	TimeZone                string `json:"timeZone"`
	MaxAmountMinor          int64  `json:"maxAmountMinor"`
	MatchingCapPeriod       string `json:"matchingCapPeriod"`
	LessonsGrantPermissions bool   `json:"lessonsGrantPermissions"`
}
type FamilySpaceSnapshot struct {
	Activity     []SpaceEntry             `json:"activity"`
	Notices      []*SpaceNotice           `json:"notices"`
	Capabilities FamilyCapabilities       `json:"capabilities"`
	AdultWallet  *Wallet                  `json:"adultWallet,omitempty"`
	Goals        []*Goal                  `json:"goals"`
	Tasks        []*FamilyTask            `json:"tasks"`
	Errands      []*Errand                `json:"errands"`
	Allowances   []*Allowance             `json:"allowances"`
	Installments []*Installment           `json:"installments"`
	Requests     []*FamilyRequest         `json:"requests"`
	Settings     map[string]SpaceSettings `json:"settings"`
	Learning     []LessonCompletion       `json:"learning"`
	Lessons      []Lesson                 `json:"lessons"`
	Weekly       []WeeklyOverview         `json:"weekly"`
}

// SpaceCommand is intentionally flat so native clients can issue bounded typed commands.
type SpaceCommand struct {
	Reason          string         `json:"reason,omitempty"`
	AnswerIndex     *int           `json:"answerIndex,omitempty"`
	Type            string         `json:"type"`
	ChildID         string         `json:"childId"`
	EntityID        string         `json:"entityId,omitempty"`
	Title           string         `json:"title,omitempty"`
	AmountMinor     int64          `json:"amountMinor,omitempty"`
	BudgetMinor     int64          `json:"budgetMinor,omitempty"`
	RewardMinor     int64          `json:"rewardMinor,omitempty"`
	TargetMinor     int64          `json:"targetMinor,omitempty"`
	Action          string         `json:"action,omitempty"`
	IdempotencyKey  string         `json:"idempotencyKey"`
	Funding         string         `json:"funding,omitempty"`
	OwnMoneyConsent bool           `json:"ownMoneyConsent,omitempty"`
	Frequency       string         `json:"frequency,omitempty"`
	Weekdays        []int          `json:"weekdays,omitempty"`
	MonthDay        int            `json:"monthDay,omitempty"`
	NextDate        string         `json:"nextDate,omitempty"`
	RetryLimit      int            `json:"retryLimit,omitempty"`
	Settings        *SpaceSettings `json:"settings,omitempty"`
	Policy          *Policy        `json:"policy,omitempty"`
	Kind            string         `json:"kind,omitempty"`
	Approve         *bool          `json:"approve,omitempty"`
}
