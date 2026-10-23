package api

// Notices are an in-app inbox, not OS push. No adult amounts, sibling names,
// session metadata or credentials are copied into them. Routine preferences
// cannot suppress financial confirmations or required decisions.
var noticeTitles = map[string]string{
	"card.block":      "Карта заблокирована",
	"wallet.transfer": "Семейный перевод", "goal.create": "Новая цель", "goal.move": "Деньги в цели", "goal.match": "Поддержка цели", "task.create": "Новое задание", "task.action": "Обновление задания", "errand.create": "Новое поручение", "errand.action": "Обновление поручения", "allowance.create": "Карманные деньги", "allowance.update": "Расписание изменено", "allowance.action": "Изменение карманных денег", "request.create": "Новый запрос", "request.decide": "Ответ на запрос", "settings.update": "Настройки обновлены", "lesson.complete": "Тема пройдена", "allowance.paid": "Карманные деньги получены", "allowance.insufficient": "Выплата ожидает решения", "allowance.missed": "Пропущенная выплата",
}

func (s *Server) addNotice(st *State, cid, recipient, kind, body string, mandatory bool) {
	f := st.FamilySpace
	if !mandatory && !settingsFor(f, cid).Notifications {
		return
	}
	if len(f.Notices) >= 2000 {
		var oldest *SpaceNotice
		for _, n := range f.Notices {
			if oldest == nil || n.CreatedAt < oldest.CreatedAt || n.CreatedAt == oldest.CreatedAt && n.ID < oldest.ID {
				oldest = n
			}
		}
		if oldest != nil {
			delete(f.Notices, oldest.ID)
		}
	}
	n := &SpaceNotice{ID: id(), ChildID: cid, Recipient: recipient, Kind: kind, Title: noticeTitles[kind], Body: body, CreatedAt: s.cfg.Now().Unix(), Mandatory: mandatory}
	f.Notices[n.ID] = n
}
func (s *Server) commandNotice(st *State, c *Child, a *Session, in SpaceCommand) {
	recipient := "adult"
	if a.Role == "adult" {
		recipient = "child"
	}
	mandatory := true
	switch in.Type {
	case "goal.create", "goal.move", "task.create", "errand.create", "allowance.create", "lesson.complete":
		mandatory = false
	}
	body := "Откройте раздел, чтобы посмотреть обновление."
	switch in.Type {
	case "allowance.update":
		body = "Будущие выплаты настроены заново. Уже созданные начисления не изменены."
	case "card.block":
		body = "Оплата картой остановлена. Разблокировать карту может взрослый."
	case "wallet.transfer":
		body = "Деньги переведены на доступный остаток."
	case "goal.match":
		body = "Поддержка взрослого зачислена в цель."
	case "request.create":
		body = "Ожидается ответ взрослого."
	case "request.decide":
		body = "Взрослый ответил на запрос."
	case "task.action":
		body = actionNotice(in.Action)
	case "errand.action":
		body = actionNotice(in.Action)
	case "lesson.complete":
		body = "Ответ на вопрос проверен. Тема отмечена как пройденная."
	}
	if in.Action == "cancel" && in.Reason != "" {
		body += " Причина: " + in.Reason
	}
	s.addNotice(st, c.ID, recipient, in.Type, body, mandatory)
}

func actionNotice(action string) string {
	switch action {
	case "accept":
		return "Предложение принято."
	case "submit":
		return "Выполнение отправлено на проверку."
	case "approve":
		return "Выполнение одобрено, расчёт завершён."
	case "cancel":
		return "Взрослый отменил предложение."
	case "clarify":
		return "Нужно уточнить выполнение."
	case "dispute":
		return "Нужно обсудить ситуацию."
	case "return":
		return "Остаток поручения возвращён."
	case "fund":
		return "Бюджет поручения выделен."
	case "request_cancel":
		return "Предложено отменить выполнение."
	case "agree_cancel":
		return "Отмена согласована."
	}
	return "Статус обновлён."
}
