//
//  StringHelper.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 10/09/2019.
//

import Foundation

struct TimeLineString {
    var titleToolbar = IBLocalizedString("title_toolbar")
    var today = IBLocalizedString("today")
    var noMorePreviousEvents = IBLocalizedString("no_more_previous_events")
    var noMoreComingEvents = IBLocalizedString("no_more_coming_events")
    var emptyStateSubtitle = IBLocalizedString("info_empty_state_subtitle")
    var infoToolbar = IBLocalizedString("message_info_toolbar")
    var noEventToday = IBLocalizedString("no_event_today")
}

struct GeneralString {
    var errorUnknow = IBLocalizedString("general_error_unknow")
    var languageKey = IBLocalizedString("general_language_key")
    var loading = IBLocalizedString("generic_popup_loading")
    var loadingLabel = IBLocalizedString("loading_label_moment")
    var errorTitle = IBLocalizedString("info_error_title")
    var emptyState = IBLocalizedString("info_empty_state_title")
    let safeConnectionLabel = IBLocalizedString("generic_label_secureConnection")
    let timeLineErrorTitle = IBLocalizedString("timeline_title_error")
    let timeLineErrorDescripcion = IBLocalizedString("timeline_text_noPredictions")
    let timeLineErrorWidgetTitle = IBLocalizedString("timeline_title_error_widget")
    let timeLineErrorWidgetDescripcion = IBLocalizedString("timeline_text_noPredictions_widget")
}

struct TimeLineDetailString {
    var calculatedDefectLabel = IBLocalizedString("timeline.timelinedetailSection.calculateDefectLabel")
    var issueDate = IBLocalizedString("issue_date")
    var deferredIssueDate = IBLocalizedString("deferred_issue_date")
    var arrangementDate = IBLocalizedString("arrengement_date")
    var toTitle = IBLocalizedString("timeline.timelinedetailSection.defferred.to.title")
    var frequency = IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.title")
    var undefined = IBLocalizedString("timeline.timelinedetailSection.defferred.undefined")
    var sameDay = IBLocalizedString("timeline.timelinedetailSection.alert.sameDay")
    var dayBefore = IBLocalizedString("timeline.timelinedetailSection.alert.dayBefore")
    var weekBefore = IBLocalizedString("timeline.timelinedetailSection.alert.weekBefore")
    var remindMe = IBLocalizedString("timeline.timelinedetailSection.alert.remindme")
    var alerCreated = IBLocalizedString("timeline.timelinedetailSection.alert.created")
    var alertError = IBLocalizedString("timeline.timelinedetailSection.alert.error")
    var alertEdited = IBLocalizedString("timeline.timelinedetailSection.alert.edited")
    var alertDeleted = IBLocalizedString("timeline.timelinedetailSection.alert.deleted")
    var alertAccept = IBLocalizedString("timeline.timelinedetailSection.alert.accept")
    var deleteAlertTitle = IBLocalizedString("timeline.timelinedetailSection.alert.delete.alert.title")
    var deleteAlertMessage = IBLocalizedString("timeline.timelinedetailSection.alert.delete.alert.message")
    var confirm = IBLocalizedString("timeline.timelinedetailSection.alert.delete.alert.confirm")
    var cancel = IBLocalizedString("timeline.timelinedetailSection.alert.delete.alert.cancel")
    var eventModified = IBLocalizedString("timeline.timelinedetailSection.event.modified")
    var chartDisclaimer = IBLocalizedString("timeline.timelinedetailSection.chart.disclaimer")
}

struct CTAsString {
    var deleteAlert = IBLocalizedString("cta.remindme.delete")
}

struct CustomEventsString {
    var title = IBLocalizedString("timeline.customeventsSection.title")
    var errorTitle = IBLocalizedString("timeline.customeventsSection.error.title")
    var errorSubTitle = IBLocalizedString("timeline.customeventsSection.error.subtitle")
    var noEventsTitle = IBLocalizedString("timeline.customeventsSection.noEvents.title")
    var noEventsMessage = IBLocalizedString("timeline.customeventsSection.noEvents.message")
    var noEventsCreateNewButton = IBLocalizedString("timeline.customeventsSection.noEvents.createNewButton.title")
}

struct CustomEventDetailString {
    var title = IBLocalizedString("timeline.customeventdetailSection.title")
    var startDate = IBLocalizedString("timeline.customeventdetailSection.startDate")
    var endDate = IBLocalizedString("timeline.customeventdetailSection.endDate")
    var frequency = IBLocalizedString("timeline.customeventdetailSection.frequency")
    var none = IBLocalizedString("timeline.customeventdetailSection.frequency.none")
    var weekly = IBLocalizedString("timeline.customeventdetailSection.frequency.weekly")
    var twoWeeks = IBLocalizedString("timeline.customeventdetailSection.frequency.twoweeks")
    var monthly = IBLocalizedString("timeline.customeventdetailSection.frequency.monthly")
    var annually = IBLocalizedString("timeline.customeventdetailSection.frequency.annually")
    var deleteEventTitle = IBLocalizedString("timeline.customeventdetailSection.delete.event.alert.title")
    var deleteEventMessage = IBLocalizedString("timeline.customeventdetailSection.delete.event.alert.message")
    var alertError = IBLocalizedString("timeline.customeventdetailSection.delete.event.alert.error")
    var deleteEventSucceedAlertMessage = IBLocalizedString("timeline.customeventdetailSection.delete.event.succeed.alert.message")
}

struct MenuTitle {
    var createEvent = IBLocalizedString("menu.create.event")
    var setup = IBLocalizedString("menu.setup")
    var personalEvents = IBLocalizedString("menu.personal.events")
    var export = IBLocalizedString("menu.export")
    var help = IBLocalizedString("menu.help")
}


struct ExportEventString {
    var info = IBLocalizedString("export.event.info")
    var allTimeOption = IBLocalizedString("export.event.all.time.option")
    var thisMonthoOtion = IBLocalizedString("export.event.all.month.event.option")
    var withFilterAppliedOption = IBLocalizedString("export.event.with.filter.option")
    var withSpecificTypeOption = IBLocalizedString("export.event.specific.type.option")
}

struct SetupString {
    var displayDateTitle = IBLocalizedString("setup.display.date.title")
    var showOnlyFuture = IBLocalizedString("setup.show.only.future.movements.option")
    var months = IBLocalizedString("setup.moths.title")
    var pluralmonths = IBLocalizedString("setup.months.actual.plural")
    var singularMonths = IBLocalizedString("setup.months.actual.singular")
    var displayProductsTitle = IBLocalizedString("setup.display.products.title")
    var accounts = IBLocalizedString("setup.product.accounts.title")
    var cards = IBLocalizedString("setup.product.cards.title")
    var selectAll = IBLocalizedString("setup.select.all.product")
    var displayByType = IBLocalizedString("setup.display.movements.type.title")
    var confirm = IBLocalizedString("setup.confirm")
}
