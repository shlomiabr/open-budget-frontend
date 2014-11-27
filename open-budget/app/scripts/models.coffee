dateToTimestamp = (date) ->
    if !date? then return null
    date = date.split('/')
    date = new Date(parseInt(date[2]),parseInt(date[1])-1,parseInt(date[0]))
    date.valueOf()

class ChangeExplanation extends Backbone.Model

        defaults:
                year: null
                leading_item: null
                req_code: null
                req_id: null
                explanation: null

        requestId: ->
            if @get('req_id')?
                @get('req_id')
            else
                ret = ""+@get('req_code')
                while ret.length < 3
                        ret = "0"+ret
                ret = @get('leading_item')+'-'+ret
                while ret.length < 6
                        ret = "0"+ret
                ret

        doFetch: ->
                @fetch(dataType: window.pageModel.get('dataType'))

        url: () => "#{window.pageModel.get('baseURL')}/api/change_expl/#{@requestId()}/#{@get('year')}"

class ChangeLine extends Backbone.Model

        defaults:
                gross_expense_diff: null
                req_code: null
                committee_id: null
                allocated_income_diff: null
                personnel_max_diff: null
                explanation: null
                change_type_name: null
                net_expense_diff: null
                change_title: null
                budget_title: null
                commitment_limit_diff: null
                leading_item: null
                budget_code: null
                year: null
                date: null
                date_type: null
                req_title: null
                change_code: null
                change_type_id: null

        requestId: ->
                ret = ""+@get('req_code')
                while ret.length < 3
                        ret = "0"+ret
                ret = @get('leading_item')+'-'+ret
                while ret.length < 6
                        ret = "0"+ret
                ret

        dateType: ->
                date_type = @get('date_type')
                if date_type == 0
                    ret = "approved"
                if date_type == 1
                    ret = "approved-approximate"
                if date_type == 10
                    ret = "pending"
                console.log 'date_type', date_type, ret
                ret

        initialize: ->
                dateStr = @get 'date'
                if dateStr?
                        @setTimestamp()
                else
                        @on 'change:date', =>
                                @setTimestamp()

        setTimestamp: ->
                @set 'timestamp', dateToTimestamp(@get 'date')

class BudgetItem extends Backbone.Model

        defaults:
                net_allocated: null
                code: null
                gross_allocated: null
                title: null
                gross_revised: null
                gross_used: null
                depth: null
                net_revised: null
                year: null
                net_used: null
                orig_codes: []

        initialize: (options) ->
            @pageModel = options.pageModel

        do_fetch: ->
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        get_class: ->
            window.changeClass( @get('net_allocated'), @get('net_revised') )

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{@get('code')}/#{@get('year')}"


class BudgetItemKids extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @year = options.year
            @code = options.code
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/kids"


class BudgetItemDepth extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @year = options.year
            @code = options.code
            @depth = options.depth
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/depth/#{@depth}?limit=1000"

class CompareRecord extends Backbone.Model
    defaults:
        code: null
        title: null
        orig_2014: null
        orig_2015: null
        rev_2014: null
        rev_2015: null
        group_top: null
        grouo_full: null

class CompareRecords extends Backbone.Collection

        model: CompareRecord

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/sysprop/budget-comparisons"

        parse: (response) ->
            response.value

class BudgetApproval extends Backbone.Model
    defaults:
        year: null
        approval_date: null
        effect_date: null
        end_date: null
        approval_timestamp: null
        effect_timestamp: null
        end_timestamp: null
        link: null

    setTimestamps: ->
        @set 'approval_timestamp', dateToTimestamp(@get 'approval_date')
        @set 'effect_timestamp', dateToTimestamp(@get 'effect_date')
        @set 'end_timestamp', dateToTimestamp(@get 'end_date')

class BudgetApprovals extends Backbone.Collection
    model: BudgetApproval

    initialize: (models, options) ->
        @pageModel = options.pageModel
        @fetch(dataType: @pageModel.get('dataType'), reset: true)

    url: ->
        "#{pageModel.get('baseURL')}/api/budget/#{pageModel.get('budgetCode')}/approvals"


class ChangeLines extends Backbone.Collection

        model: ChangeLine

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changes/#{pageModel.get('budgetCode')}"

        comparator: 'req_code'

class ChangeGroup extends Backbone.Model

        defaults:
                req_titles: []
                transfer_ids: []
                committee_ids: []
                budget_codes: []
                prefixes: []
                year: null
                date: null
                group_id: null
                changes: []
                pending: false

        initialize: (options) ->
                @pageModel = options.pageModel
                dateStr = @get 'date'
                if dateStr?
                    @setTimestamp()
                else
                    @on 'change:date', =>
                        @setTimestamp()

        setTimestamp: ->
                @set 'timestamp', dateToTimestamp(@get 'date')

        getCodeChanges: (code) =>
                _.filter(@get('changes'),(c)->c.budget_code==code)[0]

        getDateType: () =>
                if @get('pending') then "pending" else "approved"

        doFetch: ->
                @fetch(dataType: @pageModel.get('dataType'))

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('changeGroupId')}/#{@pageModel.get('year')}"

class ChangeGroups extends Backbone.Collection

        model: ChangeGroup

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('budgetCode')}?limit=1000"

class SupportLine extends Backbone.Model

    defaults:
        kind: null
        code: null
        title: null
        amount_allocated: null
        amount_supported: null
        num_used: 1
        company_id: null
        ngo_id: null
        year: null
        recipient: null
        subject: null

class TakanaSupports extends Backbone.Collection

    model: SupportLine

    comparator: (m) -> "#{m.get('year')} #{m.get('recipient')}"

    initialize: (models, options) ->
            @pageModel = options.pageModel
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

    url: ->
            "#{pageModel.get('baseURL')}/api/supports/#{@pageModel.get('budgetCode')}?limit=2000"


class BudgetHistory extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/budget/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs"

        comparator: (m) -> m.get('year')

        getLast: -> @models[@models.length-1]

class Participant extends Backbone.Model

        defaults:
                kind: ""
                name: null
                party: null
                photo_url: "data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij4NCiAgICA8cGF0aCBkPSJNMTIgMmMtNS41MiAwLTEwIDQuNDgtMTAgMTBzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwLTQuNDgtMTAtMTAtMTB6bTAgM2MxLjY2IDAgMyAxLjM0IDMgM3MtMS4zNCAzLTMgMy0zLTEuMzQtMy0zIDEuMzQtMyAzLTN6bTAgMTQuMmMtMi41IDAtNC43MS0xLjI4LTYtMy4yMi4wMy0xLjk5IDQtMy4wOCA2LTMuMDggMS45OSAwIDUuOTcgMS4wOSA2IDMuMDgtMS4yOSAxLjk0LTMuNSAzLjIyLTYgMy4yMnoiLz4NCiAgICA8cGF0aCBkPSJNMCAwaDI0djI0aC0yNHoiIGZpbGw9Im5vbmUiLz4NCjwvc3ZnPg=="
                start_date: null
                end_date: null
                title: null
                start_timestamp: null
                end_timestamp: null

        setTimestamps: ->
            @set 'start_timestamp', dateToTimestamp(@get 'start_date')
            if (@get 'end_date')?
                @set 'end_timestamp', dateToTimestamp(@get 'end_date')
            else
                @set 'end_timestamp', window.combinedHistory.maxTime

class Participants extends Backbone.Collection
        model: Participant

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @code = options.code.substring(0,4)
            @fetch(dataType: window.pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/participants/#{@code}"

class ReadyAggregator

    constructor: (event) ->
        @readyCounter = 0
        @collections = []
        @models = []
        @event = event
        @ready = false

    addModel: (model) ->
        @models.push model
        @readyCounter += 1
        model.on 'change',() => @checkIfReady(model)
        @

    addCollection: (collection) ->
        @collections.push collection
        @readyCounter += 1
        collection.on 'reset',() => @checkIfReady(collection)
        @

    checkIfReady: (what) ->
        console.log "checkIfReady: "+@event+"="+@readyCounter
        if @ready
            return
        @readyCounter -= 1
        if @readyCounter == 0
            @ready = true
            pageModel.trigger(@event)


class PageModel extends Backbone.Model

        defaults:
                budgetCode: null
                year: null
                changeGroupId: null
                mainPage: null
                baseURL: "http://www.obudget.org"
                selection: [ 0, 0 ]
                currentItem: null
                dataType: "json"#p"
                ready: false
                kinds: []
                flow: null

        initialize: ->
                if window.location.origin == @get('baseURL')
                    @set('dataType','json')
                @readyEvents = []
                @on 'change:budgetCode', ->
                    budgetCode = @get('budgetCode')
                    digits = budgetCode.length - 2
                    @set('digits',digits)
                    @article.find(".2digits,.4digits,.6digits,.8digits").css('display','none')
                    @article.find(".#{digits}digits").css('display','')
                    #@changeLines = new ChangeLines([], pageModel: @)
                    @changeGroups = new ChangeGroups([], pageModel: @)
                    @budgetApprovals = new BudgetApprovals([], pageModel: @)
                    @budgetHistory = new BudgetHistory([], pageModel: @)
                    @budgetHistory.on 'reset',
                                      () =>
                                          @set('currentItem', @budgetHistory.getLast())

                    @readyEvents.push new ReadyAggregator("ready-budget-history-pre")
                                                .addCollection(@changeGroups)
                                                .addCollection(@budgetHistory)
                                                .addCollection(@budgetApprovals)

                    if digits >= 6
                        @on('ready-budget-history', ->
                            @supports = new TakanaSupports([], pageModel: @)
                            @readyEvents.push new ReadyAggregator("ready-supports")
                                                        .addCollection(@supports)
                        )
                    readyBreadcrumbs = new ReadyAggregator("ready-breadcrumbs")
                                                    .addCollection(@budgetHistory)
                    @readyEvents.push readyBreadcrumbs
                    @breadcrumbs = []
                    maxlen=(budgetCode.length/2)-1
                    for i in [1..maxlen]
                        main = null
                        kids = null

                        if i < 5
                            code = budgetCode.slice(0,(i+1)*2)
                            main = new BudgetItem(year: @get('year'), code: code, pageModel: @)
                            readyBreadcrumbs.addModel(main)
                            main.do_fetch()
                            kids = new BudgetItemKids([], year: @get('year'), code: code, pageModel: @)
                            readyBreadcrumbs.addCollection(kids)
                            @breadcrumbs.push
                                main: main
                                kids: kids
                                last: i == maxlen

                    @on('ready-budget-history', ->
                        @participants = new Participants([], code: budgetCode, pageModel: @)
                        readyParticipants = new ReadyAggregator('ready-participants')
                                                        .addCollection(@participants)
                        @readyEvents.push readyParticipants
                    )

                @on 'change:changeGroupId', ->
                    @changeGroup = new ChangeGroup(pageModel: @)
                    @changeGroupExplanation = new ChangeExplanation(year: pageModel.get('year'), req_id: pageModel.get('changeGroupId'))
                    @readyEvents.push new ReadyAggregator("ready-changegroup")
                                                .addModel(@changeGroup)
                                                .addModel(@changeGroupExplanation)
                    @changeGroup.doFetch()
                    @changeGroupExplanation.doFetch()
                    @changeGroup.on 'change:title_template', =>
                        title_template = @changeGroup.get('title_template')
                        title_template = title_template.split('-')
                        for part in title_template
                            @addKind(part)

                @on 'change:mainPage', ->
                    @budgetItems4 = new CompareRecords([], pageModel: @)
                    @budgetItems2 = new BudgetItemKids([], year: pageModel.get('year'), code: '00', pageModel: @)
                    @readyEvents.push new ReadyAggregator("ready-budget-bubbles")
                                                        .addCollection(@budgetItems2)
                                                        .addCollection(@budgetItems4)

                    @mainBudgetItem = new BudgetItem(year: pageModel.get('year'), code: '00', pageModel: @)
                    @mainBudgetItem.do_fetch()
                    @readyEvents.push new ReadyAggregator("ready-main-budget")
                                                         .addModel(@mainBudgetItem)


                @on 'change:kinds', =>
                    for kind in @get('kinds')
                        $('body').toggleClass("kind-#{kind}",true)

        addKind: (kind) ->
            kinds = _.clone(@get('kinds'))
            kinds.push(kind)
            @set('kinds',kinds)

window.models =
        BudgetItem: BudgetItem
        ChangeLine: ChangeLine
        ChangeExplanation: ChangeExplanation

window.pageModel = new PageModel()

DEFAULT_HOME = "#main//2015/main"

$( ->
        hash = window.location.hash.substring(1)
        [kind, identifier, year, flow] = hash.split("/",4)
        year = parseInt(year)
        console.log "hash:", kind, identifier, year, flow
        if !isNaN(year)
            pageModel.set('year',year)
        else
            window.location.hash = DEFAULT_HOME
            window.location.reload()

        pageModel.set("flow",flow)
        if kind == "budget"
            pageModel.article = $("article#budget-item-article")
            pageModel.set("budgetCode",identifier)
        else if kind == "transfer"
            pageModel.article = $("article#change-group-article")
            pageModel.set("changeGroupId",identifier)
        else if kind == "main"
            pageModel.article = $("article#main-page-article")
            pageModel.set("mainPage",identifier)
        else
            window.location.hash = DEFAULT_HOME
            window.location.reload()
        $("article.single-page-article").css("display","none")
        pageModel.article.css("display","inherit")
        pageModel.addKind(kind)

)
