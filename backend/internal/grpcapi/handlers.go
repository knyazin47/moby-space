package grpcapi

import (
	"context"
	pb "moby.local/family/gen/moby/family/v1"
	"moby.local/family/internal/api"
)

func (s *Service) LoginAdult(ctx context.Context, r *pb.LoginAdultRequest) (*pb.SessionGrant, error) {
	if r == nil || (r.BootstrapSecret == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppLogin(ctx, credential(ctx), api.LoginInput{BootstrapSecret: r.GetBootstrapSecret(), DeviceName: r.GetDeviceName()})
	return finish(ctx, v, e, mapSessionGrant)
}
func (s *Service) Logout(ctx context.Context, r *pb.Empty) (*pb.Empty, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppLogout(ctx, credential(ctx))
	return finish(ctx, v, e, func(api.SuccessAck) *pb.Empty { return &pb.Empty{} })
}
func (s *Service) GetSnapshot(ctx context.Context, r *pb.Empty) (*pb.Snapshot, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppGetSnapshot(ctx, credential(ctx))
	return finish(ctx, v, e, mapSnapshot)
}
func (s *Service) CompleteFamilyIntro(ctx context.Context, r *pb.Empty) (*pb.Snapshot, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppCompleteFamilyIntro(ctx, credential(ctx))
	return finish(ctx, v, e, mapSnapshot)
}
func (s *Service) ListChildren(ctx context.Context, r *pb.Empty) (*pb.ChildrenList, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppListChildren(ctx, credential(ctx))
	return finish(ctx, v, e, func(v []*api.Child) *pb.ChildrenList {
		out := &pb.ChildrenList{}
		for _, c := range v {
			out.Children = append(out.Children, mapChild(*c))
		}
		return out
	})
}
func (s *Service) GetChild(ctx context.Context, r *pb.ChildRef) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppGetChild(ctx, credential(ctx), r.GetChildId())
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) CreateChild(ctx context.Context, r *pb.CreateChildRequest) (*pb.Child, error) {
	if r == nil || (r.DisplayName == nil || r.DateOfBirth == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppCreateChild(ctx, credential(ctx), api.ChildInput{DisplayName: r.GetDisplayName(), LegalName: r.GetLegalName(), DateOfBirth: r.GetDateOfBirth(), IdempotencyKey: r.GetIdempotencyKey()})
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) UpdateChild(ctx context.Context, r *pb.UpdateChildRequest) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil || r.Patch == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppUpdateChild(ctx, credential(ctx), r.GetChildId(), api.ChildPatch{DisplayName: r.Patch.DisplayName, LegalName: r.Patch.LegalName, DateOfBirth: r.Patch.DateOfBirth, CardStatus: r.Patch.CardStatus})
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) UpdatePolicy(ctx context.Context, r *pb.UpdatePolicyRequest) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil || !completePolicy(r.Policy)) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppPolicy(ctx, credential(ctx), r.GetChildId(), inputPolicy(r.Policy))
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) ArchiveChild(ctx context.Context, r *pb.ChildRef) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppArchive(ctx, credential(ctx), r.GetChildId())
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) VerifyChild(ctx context.Context, r *pb.VerifyChildRequest) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil || r.Outcome == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppVerify(ctx, credential(ctx), r.GetChildId(), api.VerificationInput{Outcome: r.GetOutcome()})
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) OpenProduct(ctx context.Context, r *pb.OpenProductRequest) (*pb.Child, error) {
	if r == nil || (r.ChildId == nil || r.AgreementVersion == nil || r.SignerConsent == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppProduct(ctx, credential(ctx), r.GetChildId(), api.ProductInput{AgreementVersion: r.GetAgreementVersion(), SignerConsent: r.GetSignerConsent()})
	return finish(ctx, v, e, func(v *api.Child) *pb.Child { return mapChild(*v) })
}
func (s *Service) Purchase(ctx context.Context, r *pb.ChildMoneyRequest) (*pb.Operation, error) {
	if r == nil || (r.ChildId == nil || !completeMoney(r.Input)) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppMoney(ctx, credential(ctx), r.GetChildId(), inputMoney(r.Input), false)
	return finish(ctx, v, e, func(v *api.Operation) *pb.Operation { return mapOperation(*v) })
}
func (s *Service) TopUp(ctx context.Context, r *pb.ChildMoneyRequest) (*pb.Operation, error) {
	if r == nil || (r.ChildId == nil || !completeMoney(r.Input)) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppMoney(ctx, credential(ctx), r.GetChildId(), inputMoney(r.Input), true)
	return finish(ctx, v, e, func(v *api.Operation) *pb.Operation { return mapOperation(*v) })
}
func (s *Service) DecideOperation(ctx context.Context, r *pb.DecideOperationRequest) (*pb.Operation, error) {
	if r == nil || (r.OperationId == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppDecision(ctx, credential(ctx), r.GetOperationId(), api.DecisionInput{Approve: r.Approve})
	return finish(ctx, v, e, func(v *api.Operation) *pb.Operation { return mapOperation(*v) })
}
func (s *Service) CreatePairing(ctx context.Context, r *pb.CreatePairingRequest) (*pb.PairingCreated, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppCreatePair(ctx, credential(ctx), api.CreatePairInput{DeviceName: r.GetDeviceName()})
	return finish(ctx, v, e, mapPairingCreated)
}
func (s *Service) ConsumePairing(ctx context.Context, r *pb.ConsumePairingRequest) (*pb.PairingResult, error) {
	if r == nil || (r.Code == nil || r.ChildId == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppConsumePair(ctx, credential(ctx), api.ConsumePairInput{Code: r.GetCode(), ChildID: r.GetChildId()})
	return finish(ctx, v, e, mapPairingResult)
}
func (s *Service) PollPairing(ctx context.Context, r *pb.PairingSecretRequest) (*pb.PairingPoll, error) {
	if r == nil || (r.PairingId == nil || r.RequestSecret == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppPollPair(ctx, credential(ctx), r.GetPairingId(), api.PairSecretInput{RequestSecret: r.GetRequestSecret()})
	return finish(ctx, v, e, mapPairingPoll)
}
func (s *Service) CancelPairing(ctx context.Context, r *pb.PairingSecretRequest) (*pb.PairingResult, error) {
	if r == nil || (r.PairingId == nil || r.RequestSecret == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppCancelPair(ctx, credential(ctx), r.GetPairingId(), api.PairSecretInput{RequestSecret: r.GetRequestSecret()})
	return finish(ctx, v, e, mapPairingResult)
}
func (s *Service) ListSessions(ctx context.Context, r *pb.Empty) (*pb.SessionsList, error) {
	if r == nil || (false) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppListSessions(ctx, credential(ctx))
	return finish(ctx, v, e, func(v []api.SessionSummary) *pb.SessionsList {
		out := &pb.SessionsList{}
		for _, x := range v {
			out.Sessions = append(out.Sessions, mapSessionSummary(x))
		}
		return out
	})
}
func (s *Service) RevokeSession(ctx context.Context, r *pb.SessionRef) (*pb.Empty, error) {
	if r == nil || (r.SessionId == nil) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppRevoke(ctx, credential(ctx), r.GetSessionId())
	return finish(ctx, v, e, func(api.SuccessAck) *pb.Empty { return &pb.Empty{} })
}
func (s *Service) ExecuteFamilySpaceCommand(ctx context.Context, r *pb.SpaceCommand) (*pb.Snapshot, error) {
	if r == nil || (!completeSpaceCommand(r)) {
		return nil, invalid(ctx, "invalid_body")
	}
	v, e := s.store.AppSpaceCommand(ctx, credential(ctx), inputSpaceCommand(r))
	return finish(ctx, v, e, mapSnapshot)
}

func completePolicy(p *pb.Policy) bool {
	return p != nil && p.Payments != nil && p.Transfers != nil && p.Internet != nil && p.DailyLimit != nil && p.MonthlyLimit != nil && p.ApprovalThreshold != nil
}
func completeSettings(p *pb.SpaceSettings) bool {
	return p != nil && p.MatchingEnabled != nil && p.MatchingPercent != nil && p.MatchingCapMinor != nil && p.Notifications != nil && p.TasksEnabled != nil && p.ErrandsEnabled != nil && p.LearningEnabled != nil
}
func completeMoney(p *pb.MoneyInput) bool {
	return p != nil && p.AmountMinor != nil && p.Currency != nil && p.IdempotencyKey != nil
}
func inputMoney(p *pb.MoneyInput) api.MoneyInput {
	return api.MoneyInput{AmountMinor: p.GetAmountMinor(), Currency: p.GetCurrency(), Channel: p.GetChannel(), Category: p.GetCategory(), Merchant: p.GetMerchant(), IdempotencyKey: p.GetIdempotencyKey()}
}
func completeSpaceCommand(p *pb.SpaceCommand) bool {
	if p == nil || p.Type == nil || p.ChildId == nil || p.IdempotencyKey == nil {
		return false
	}
	if p.Policy != nil && !completePolicy(p.Policy) {
		return false
	}
	if p.Settings != nil && !completeSettings(p.Settings) {
		return false
	}
	switch p.GetType() {
	case "wallet.transfer", "goal.move", "goal.match":
		return p.AmountMinor != nil
	case "goal.create":
		return p.TargetMinor != nil
	case "task.create":
		return p.RewardMinor != nil
	case "errand.create":
		return p.BudgetMinor != nil
	case "errand.action":
		return p.GetAction() != "submit" || p.AmountMinor != nil
	case "allowance.create", "allowance.update":
		return p.AmountMinor != nil && p.Frequency != nil && p.NextDate != nil
	case "request.create":
		return p.GetKind() != "money" || p.AmountMinor != nil
	}
	return true
}
