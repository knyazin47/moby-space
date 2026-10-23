package grpcapi

import (
	pb "moby.local/family/gen/moby/family/v1"
	api "moby.local/family/internal/api"
)

func ptr[T any](v T) *T { return &v }
func mapPolicy(v api.Policy) *pb.Policy {
	out := &pb.Policy{}
	if v.Categories != nil {
		out.Categories = &pb.CategoryRules{Values: map[string]bool{}}
		for k, value := range v.Categories {
			out.Categories.Values[k] = value
		}
	}
	out.Payments = ptr(v.Payments)
	out.Transfers = ptr(v.Transfers)
	out.Internet = ptr(v.Internet)
	out.DailyLimit = ptr(v.DailyLimit)
	out.MonthlyLimit = ptr(v.MonthlyLimit)
	out.ApprovalThreshold = ptr(v.ApprovalThreshold)
	return out
}
func mapChild(v api.Child) *pb.Child {
	out := &pb.Child{}
	out.Id = ptr(v.ID)
	out.DisplayName = ptr(v.DisplayName)
	out.LegalName = ptr(v.LegalName)
	out.DateOfBirth = ptr(v.DateOfBirth)
	out.IdentityStatus = ptr(v.IdentityStatus)
	out.RepresentationStatus = ptr(v.RepresentationStatus)
	out.AgreementStatus = ptr(v.AgreementStatus)
	out.AccountStatus = ptr(v.AccountStatus)
	out.CardStatus = ptr(v.CardStatus)
	out.DeviceAccessStatus = ptr(v.DeviceAccessStatus)
	out.MembershipStatus = ptr(v.MembershipStatus)
	out.Policy = mapPolicy(v.Policy)
	out.BalanceMinor = ptr(v.BalanceMinor)
	out.Currency = ptr(v.Currency)
	out.AgreementVersion = ptr(v.AgreementVersion)
	out.SignerId = ptr(v.SignerID)
	out.SignedAt = ptr(v.SignedAt)
	out.Version = ptr(v.Version)
	return out
}
func mapActor(v api.Actor) *pb.Actor {
	out := &pb.Actor{}
	out.Id = ptr(v.ID)
	out.Role = ptr(v.Role)
	out.ChildId = ptr(v.ChildID)
	out.SessionId = ptr(v.SessionID)
	return out
}
func mapAdultPreferences(v api.AdultPreferences) *pb.AdultPreferences {
	out := &pb.AdultPreferences{}
	out.FamilyIntroSeen = ptr(v.FamilyIntroSeen)
	return out
}
func mapSnapshot(v api.Snapshot) *pb.Snapshot {
	out := &pb.Snapshot{}
	out.FamilySpace = mapFamilySpaceSnapshot(v.FamilySpace)
	out.Revision = ptr(v.Revision)
	out.Actor = mapActor(v.Actor)
	if v.Preferences != nil {
		out.Preferences = mapAdultPreferences(*v.Preferences)
	}
	for _, value := range v.Children {
		out.Children = append(out.Children, mapChild(*value))
	}
	for _, value := range v.Operations {
		out.Operations = append(out.Operations, mapOperation(*value))
	}
	out.Synthetic = ptr(v.Synthetic)
	out.BusinessDate = ptr(v.BusinessDate)
	return out
}
func mapOperation(v api.Operation) *pb.Operation {
	out := &pb.Operation{}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Kind = ptr(v.Kind)
	out.AmountMinor = ptr(v.AmountMinor)
	out.Currency = ptr(v.Currency)
	out.Channel = ptr(v.Channel)
	out.Category = ptr(v.Category)
	out.CompletedAt = ptr(v.CompletedAt)
	out.Merchant = ptr(v.Merchant)
	out.Status = ptr(v.Status)
	out.CreatedAt = ptr(v.CreatedAt)
	out.Version = ptr(v.Version)
	if v.Decision != nil {
		out.Decision = ptr(*v.Decision)
	}
	return out
}
func mapWallet(v api.Wallet) *pb.Wallet {
	out := &pb.Wallet{}
	out.AvailableMinor = ptr(v.AvailableMinor)
	out.ReservedMinor = ptr(v.ReservedMinor)
	out.Currency = ptr(v.Currency)
	return out
}
func mapGoal(v api.Goal) *pb.Goal {
	out := &pb.Goal{}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Title = ptr(v.Title)
	out.TargetMinor = ptr(v.TargetMinor)
	out.SavedMinor = ptr(v.SavedMinor)
	out.MatchedMinor = ptr(v.MatchedMinor)
	out.NetDepositsMinor = ptr(v.NetDepositsMinor)
	out.MatchedBasisMinor = ptr(v.MatchedBasisMinor)
	out.MatchingAvailableMinor = ptr(v.MatchingAvailableMinor)
	out.MatchingStatus = ptr(v.MatchingStatus)
	return out
}
func mapFamilyTask(v api.FamilyTask) *pb.FamilyTask {
	out := &pb.FamilyTask{}
	out.CancelReason = ptr(v.CancelReason)
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Title = ptr(v.Title)
	out.RewardMinor = ptr(v.RewardMinor)
	out.Status = ptr(v.Status)
	out.CancelRequested = ptr(v.CancelRequested)
	return out
}
func mapErrand(v api.Errand) *pb.Errand {
	out := &pb.Errand{}
	out.CancelReason = ptr(v.CancelReason)
	out.RewardReserved = ptr(v.RewardReserved)
	out.ExpenseRecorded = ptr(v.ExpenseRecorded)
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Title = ptr(v.Title)
	out.BudgetMinor = ptr(v.BudgetMinor)
	out.RewardMinor = ptr(v.RewardMinor)
	out.ActualMinor = ptr(v.ActualMinor)
	out.ReturnedMinor = ptr(v.ReturnedMinor)
	out.Funding = ptr(v.Funding)
	out.Status = ptr(v.Status)
	out.ReturnConfirmed = ptr(v.ReturnConfirmed)
	out.OwnMoneyConsent = ptr(v.OwnMoneyConsent)
	out.CancelRequested = ptr(v.CancelRequested)
	return out
}
func mapAllowance(v api.Allowance) *pb.Allowance {
	out := &pb.Allowance{}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Title = ptr(v.Title)
	out.AmountMinor = ptr(v.AmountMinor)
	out.Frequency = ptr(v.Frequency)
	for _, value := range v.Weekdays {
		out.Weekdays = append(out.Weekdays, int32(value))
	}
	out.MonthDay = ptr(int32(v.MonthDay))
	out.NextDate = ptr(v.NextDate)
	out.RetryLimit = ptr(int32(v.RetryLimit))
	out.Active = ptr(v.Active)
	return out
}
func mapInstallment(v api.Installment) *pb.Installment {
	out := &pb.Installment{}
	if v.RetryLimit != nil {
		out.RetryLimit = ptr(int32(*v.RetryLimit))
	}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.AllowanceId = ptr(v.AllowanceID)
	out.DueDate = ptr(v.DueDate)
	out.AmountMinor = ptr(v.AmountMinor)
	out.Status = ptr(v.Status)
	out.Attempts = ptr(int32(v.Attempts))
	out.LastAttemptDate = ptr(v.LastAttemptDate)
	return out
}
func mapSpaceSettings(v api.SpaceSettings) *pb.SpaceSettings {
	out := &pb.SpaceSettings{}
	out.MatchingEnabled = ptr(v.MatchingEnabled)
	out.MatchingPercent = ptr(v.MatchingPercent)
	out.MatchingCapMinor = ptr(v.MatchingCapMinor)
	out.Notifications = ptr(v.Notifications)
	out.TasksEnabled = ptr(v.TasksEnabled)
	out.ErrandsEnabled = ptr(v.ErrandsEnabled)
	out.LearningEnabled = ptr(v.LearningEnabled)
	return out
}
func mapFamilyRequest(v api.FamilyRequest) *pb.FamilyRequest {
	out := &pb.FamilyRequest{}
	out.AmountMinor = ptr(v.AmountMinor)
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Kind = ptr(v.Kind)
	out.Title = ptr(v.Title)
	if v.Policy != nil {
		out.Policy = mapPolicy(*v.Policy)
	}
	out.Status = ptr(v.Status)
	return out
}
func mapLesson(v api.Lesson) *pb.Lesson {
	out := &pb.Lesson{}
	out.Question = ptr(v.Question)
	for _, value := range v.Options {
		out.Options = append(out.Options, value)
	}
	out.Id = ptr(v.ID)
	out.Title = ptr(v.Title)
	out.Body = ptr(v.Body)
	out.Skill = ptr(v.Skill)
	return out
}
func mapLessonCompletion(v api.LessonCompletion) *pb.LessonCompletion {
	out := &pb.LessonCompletion{}
	out.ChildId = ptr(v.ChildID)
	out.LessonId = ptr(v.LessonID)
	out.CompletedAt = ptr(v.CompletedAt)
	return out
}
func mapSpaceEntry(v api.SpaceEntry) *pb.SpaceEntry {
	out := &pb.SpaceEntry{}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Kind = ptr(v.Kind)
	out.AmountMinor = ptr(v.AmountMinor)
	out.At = ptr(v.At)
	out.EntityId = ptr(v.EntityID)
	return out
}
func mapWeeklyOverview(v api.WeeklyOverview) *pb.WeeklyOverview {
	out := &pb.WeeklyOverview{}
	out.ChildId = ptr(v.ChildID)
	out.Since = ptr(v.Since)
	out.IncomingMinor = ptr(v.IncomingMinor)
	out.SpentMinor = ptr(v.SpentMinor)
	out.SavedMinor = ptr(v.SavedMinor)
	out.TasksCompleted = ptr(int32(v.TasksCompleted))
	out.LessonsCompleted = ptr(int32(v.LessonsCompleted))
	return out
}
func mapFamilyCapabilities(v api.FamilyCapabilities) *pb.FamilyCapabilities {
	out := &pb.FamilyCapabilities{}
	out.Synthetic = ptr(v.Synthetic)
	out.Currency = ptr(v.Currency)
	out.TimeZone = ptr(v.TimeZone)
	out.MaxAmountMinor = ptr(v.MaxAmountMinor)
	out.MatchingCapPeriod = ptr(v.MatchingCapPeriod)
	out.LessonsGrantPermissions = ptr(v.LessonsGrantPermissions)
	return out
}
func mapSpaceNotice(v api.SpaceNotice) *pb.SpaceNotice {
	out := &pb.SpaceNotice{}
	out.Id = ptr(v.ID)
	out.ChildId = ptr(v.ChildID)
	out.Recipient = ptr(v.Recipient)
	out.Title = ptr(v.Title)
	out.Body = ptr(v.Body)
	out.Kind = ptr(v.Kind)
	out.CreatedAt = ptr(v.CreatedAt)
	out.Read = ptr(v.Read)
	out.Mandatory = ptr(v.Mandatory)
	return out
}
func mapFamilySpaceSnapshot(v api.FamilySpaceSnapshot) *pb.FamilySpaceSnapshot {
	out := &pb.FamilySpaceSnapshot{}
	for _, value := range v.Activity {
		out.Activity = append(out.Activity, mapSpaceEntry(value))
	}
	for _, value := range v.Notices {
		out.Notices = append(out.Notices, mapSpaceNotice(*value))
	}
	out.Capabilities = mapFamilyCapabilities(v.Capabilities)
	if v.AdultWallet != nil {
		out.AdultWallet = mapWallet(*v.AdultWallet)
	}
	for _, value := range v.Goals {
		out.Goals = append(out.Goals, mapGoal(*value))
	}
	for _, value := range v.Tasks {
		out.Tasks = append(out.Tasks, mapFamilyTask(*value))
	}
	for _, value := range v.Errands {
		out.Errands = append(out.Errands, mapErrand(*value))
	}
	for _, value := range v.Allowances {
		out.Allowances = append(out.Allowances, mapAllowance(*value))
	}
	for _, value := range v.Installments {
		out.Installments = append(out.Installments, mapInstallment(*value))
	}
	for _, value := range v.Requests {
		out.Requests = append(out.Requests, mapFamilyRequest(*value))
	}
	out.Settings = map[string]*pb.SpaceSettings{}
	for k, value := range v.Settings {
		out.Settings[k] = mapSpaceSettings(value)
	}
	for _, value := range v.Learning {
		out.Learning = append(out.Learning, mapLessonCompletion(value))
	}
	for _, value := range v.Lessons {
		out.Lessons = append(out.Lessons, mapLesson(value))
	}
	for _, value := range v.Weekly {
		out.Weekly = append(out.Weekly, mapWeeklyOverview(value))
	}
	return out
}
func mapSessionGrant(v api.SessionGrant) *pb.SessionGrant {
	out := &pb.SessionGrant{}
	out.Token = ptr(v.Token)
	out.Actor = mapActor(v.Actor)
	out.ExpiresAt = ptr(v.ExpiresAt)
	return out
}
func mapPairingCreated(v api.PairingCreated) *pb.PairingCreated {
	out := &pb.PairingCreated{}
	out.Id = ptr(v.ID)
	out.Code = ptr(v.Code)
	out.RequestSecret = ptr(v.RequestSecret)
	out.ExpiresAt = ptr(v.ExpiresAt)
	out.Status = ptr(v.Status)
	return out
}
func mapPairingResult(v api.PairingResult) *pb.PairingResult {
	out := &pb.PairingResult{}
	out.Id = ptr(v.ID)
	out.Status = ptr(v.Status)
	out.ChildId = ptr(v.ChildID)
	return out
}
func mapPairingPoll(v api.PairingPoll) *pb.PairingPoll {
	out := &pb.PairingPoll{}
	out.Status = ptr(v.Status)
	if v.Session != nil {
		out.Session = mapSessionGrant(*v.Session)
	}
	return out
}
func mapSessionSummary(v api.SessionSummary) *pb.SessionSummary {
	out := &pb.SessionSummary{}
	out.Id = ptr(v.ID)
	out.Role = ptr(v.Role)
	out.ChildId = ptr(v.ChildID)
	out.DeviceName = ptr(v.DeviceName)
	out.ExpiresAt = ptr(v.ExpiresAt)
	out.Revoked = ptr(v.Revoked)
	return out
}
func inputPolicy(p *pb.Policy) api.Policy {
	v := api.Policy{}
	if p == nil {
		return v
	}
	if p.Categories != nil {
		v.Categories = map[string]bool{}
		for k, x := range p.Categories.Values {
			v.Categories[k] = x
		}
	}
	v.Payments = p.GetPayments()
	v.Transfers = p.GetTransfers()
	v.Internet = p.GetInternet()
	v.DailyLimit = p.GetDailyLimit()
	v.MonthlyLimit = p.GetMonthlyLimit()
	v.ApprovalThreshold = p.GetApprovalThreshold()
	return v
}
func inputSpaceSettings(p *pb.SpaceSettings) api.SpaceSettings {
	v := api.SpaceSettings{}
	if p == nil {
		return v
	}
	v.MatchingEnabled = p.GetMatchingEnabled()
	v.MatchingPercent = p.GetMatchingPercent()
	v.MatchingCapMinor = p.GetMatchingCapMinor()
	v.Notifications = p.GetNotifications()
	v.TasksEnabled = p.GetTasksEnabled()
	v.ErrandsEnabled = p.GetErrandsEnabled()
	v.LearningEnabled = p.GetLearningEnabled()
	return v
}
func inputSpaceCommand(p *pb.SpaceCommand) api.SpaceCommand {
	v := api.SpaceCommand{}
	if p == nil {
		return v
	}
	v.Reason = p.GetReason()
	if p.AnswerIndex != nil {
		x := int(*p.AnswerIndex)
		v.AnswerIndex = &x
	}
	v.Type = p.GetType()
	v.ChildID = p.GetChildId()
	v.EntityID = p.GetEntityId()
	v.Title = p.GetTitle()
	v.AmountMinor = p.GetAmountMinor()
	v.BudgetMinor = p.GetBudgetMinor()
	v.RewardMinor = p.GetRewardMinor()
	v.TargetMinor = p.GetTargetMinor()
	v.Action = p.GetAction()
	v.IdempotencyKey = p.GetIdempotencyKey()
	v.Funding = p.GetFunding()
	v.OwnMoneyConsent = p.GetOwnMoneyConsent()
	v.Frequency = p.GetFrequency()
	for _, x := range p.Weekdays {
		v.Weekdays = append(v.Weekdays, int(x))
	}
	v.MonthDay = int(p.GetMonthDay())
	v.NextDate = p.GetNextDate()
	v.RetryLimit = int(p.GetRetryLimit())
	if p.Settings != nil {
		x := inputSpaceSettings(p.Settings)
		v.Settings = &x
	}
	if p.Policy != nil {
		x := inputPolicy(p.Policy)
		v.Policy = &x
	}
	v.Kind = p.GetKind()
	v.Approve = p.Approve
	return v
}
