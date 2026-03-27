/* eslint-disable */
import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEventList from '@salesforce/apex/EventBooking_Sch.fetchEventList';
import getAllDaysCon from '@salesforce/apex/EventBooking_Sch.getAllDaysCon';
import getEventDetail from '@salesforce/apex/EventBooking_Sch.getEventDetail';
import updateFilledEvent from '@salesforce/apex/EventBooking_Sch.updateFilledEvent';
import createEventBookings from '@salesforce/apex/EventBooking_Sch.createEventBookings';
import getSearchRecords from '@salesforce/apex/EventBooking_Sch.getSearchRecords';
import schedulingapp from '@salesforce/resourceUrl/schedulingapp';


export default class EventBooking extends LightningElement {
    @track isLoading = true;
    @track errorMessage = '';
    @track successMessage = '';
    @track activeEventType = 'today';
    @track futureEvents = 0;
    @track todaysEvents = 0;
    @track thisWeeksEvents = 0;
    @track nextWeeksEvents = 0;
    @track filterName = '';
    @track filterLocation = '';
    @track filterType = '';
    @track locationList = [];
    @track typeOfEventList = [];
    @track isFullEvent = [];
    @track view = 'grid';
    @track eventListWP = [];
    @track todayEventListWP = [];
    @track thisWeekEventListWP = [];
    @track nextWeekEventListWP = [];
    @track futureEventListWP = [];
    @track fullEventListWP = [];
    @api eventId = '';
    @track container = {};
    @track mainDateColumnList = [];
    @track newDateColumnList = [];
    @track selectedSchedules = [];
    @track selectedDcLOC = '';
    @track locOptions = [];
    @track disableNext = true;
    @track disableForm = true;
    @track event = { sobjectType: 'Event__c' };
    @track location = '';
    @track agendaList = [];
    @track sponsorList = [];
    @track speakerList = [];
    @track facilitatorList = [];
    @track volunteerList = [];
    @track searchClientString = '';
    @track srList = [];
    @track showSearchIcons = true;
    @track showSearchPanel = false;
    @track createReg = {
    sobjectType: 'Registration__c',
    Customer_Name__c: '',
    Customer_Lastname__c: '',
    Customer_Email__c: '',
    Customer_Contact__c: ''
};
    @track newRegistrations = [];
    @track regCheckIn = false;
    @track regQuantity = 0;
    @track calculatedQuantity = 1;
    @track quantityList = [];
    @track showEvtDetails = false;
    @track bookingType = 'group';
    @track parentRegs = [];
    @track childRegs = [];
    @track result = [];
    @track resultReg = { sobjectType: 'Registration__c' };
    @track loopValidation = false;
    @track bookingSuccess = false;
    @track scanValue = '';
    @track startdateReg ='';
    @track showFilterOptions = false;
    @track changefiltervalues =true;
    @track selectedRange = 'today'; // default selection
    @track showDate;
    @track isSlot=false;
    firstName = '';
lastName = '';
    // Get dynamic class for Grid icon
    get gridClass() {
        return `toggle-icon ${this.view === 'grid' ? 'active' : ''}`;
    }

    // Get dynamic class for List icon
    get listClass() {
        return `toggle-icon ${this.view === 'list' ? 'active' : ''}`;
    }
    get todayIconVariant() {
    return this.selectedRange === 'today' ? 'inverse' : 'brand';
}
 get weekIconVariant() {
    return this.selectedRange === 'thisWeek' ? 'inverse' : 'brand';
}

 get nextIconVariant() {
    return this.selectedRange === 'nextWeek' ? 'inverse' : 'brand';
}
get futureIconVariant() {
    return this.selectedRange === 'future' ? 'inverse' : 'brand';
}

    // Method to toggle views

    toggleFilters() {
        this.showFilterOptions = !this.showFilterOptions;
    }
    // Example method to set values and compute error classes
    updateRegistrations(data) {
        this.newRegistrations = data.map((reg) => {
            return {
                ...reg,
                classLastname: this.loopValidation && !reg.Customer_Lastname__c ? 'slds-has-error' : '',
                classEmail: this.loopValidation && !reg.Customer_Email__c ? 'slds-has-error' : '',
                classPhone: this.loopValidation && !reg.Customer_Contact__c ? 'slds-has-error' : ''
            };
        });
    }

    // Call this when validating
    validateInputs() {
        this.loopValidation = true;
        this.updateRegistrations(this.newRegistrations);
    }
nameChange(event){
        const fieldName = event.target.value;

        const key = event.target.dataset.field;
this.createReg = { ...this.createReg, [key]: fieldName };

}

     get showDateColumns() {
    return this.newDateColumnList.length > 0 && !this.showEvtDetails;
} get noshowDateColumns() {
    return this.newDateColumnList.length > 0 && this.showEvtDetails;
}
 get todaysEventsClass() {
        return this.todaysEvents > 0 ? 'printQR' : 'printQRdisable';
    }

    // Computed properties for button classes
    get todayButtonClass() {
        return this.activeEventType === 'today'
            ? 'control btn btn-common active-btn mr-1'
            : 'control btn btn-common mr-1';
    }

    get thisWeekButtonClass() {
        return this.activeEventType === 'thisWeek'
            ? 'control btn btn-common active-btn mr-1 '
            : 'control btn btn-common mr-1';
    }

    get nextWeekButtonClass() {
        return this.activeEventType === 'nextWeek'
            ? 'control btn btn-common active-btn mr-1'
            : 'control btn btn-common mr-1 ';
    }

    get futureButtonClass() {
        return this.activeEventType === 'future'
            ? 'control btn btn-common active-btn mr-1'
            : 'control btn btn-common mr-1';
    }
    get computedClass() {
        return this.view === 'grid' ? 'eb15 acitve-list2' : 'eb16';
    }
    get isGridView() {
    return this.view === 'grid';
    }
    get isListView() {
    return this.view === 'list';
    }
    get newDateColumnListWithClasses() {
    return this.newDateColumnList.map((slot, index) => {
        const isDropIn = slot.Event?.Event_Type__c === 'Drop-in';
        const isZeroQty = slot.AvailableQuantity === 0;

        // Compute card class
        const cardClass = slot.isSelect
            ? 'day shadow-sm day-active'
            : !isDropIn && isZeroQty
                ? 'day shadow-sm eb66'
                : 'day shadow-sm';

        // Compute right arrow panel class and style
        const sidePanelClass = !isDropIn && isZeroQty
            ? 'slds-col col-1 pl-0 cursor-not-allowed'
            : 'slds-col col-1 pl-0';

        const sidePanelStyle = !isDropIn && isZeroQty
            ? 'cursor:not-allowed;pointer-events:none;font-size:10px;text-align:right;padding-right:10px;background:#8acbff;min-height:61px;line-height:60px;border-radius:0px 6px 6px 0px;'
            : 'font-size:10px;text-align:right;padding-right:10px;background:#8acbff;min-height:61px;line-height:60px;border-radius:0px 6px 6px 0px;';

        // Flag for showing quantity rows
        const showQuantities = !isDropIn;

        return {
            ...slot,
            cardClass,
            sidePanelClass,
            sidePanelStyle,
            showQuantities
        };
    });
}
get showSearchPanelSection() {
    return this.srList.length > 0 && this.showSearchPanel;
}
get hasMultipleLocOptions() {
    return this.locOptions && this.locOptions.length > 1;
}

    get eventListWithExtras() {
    return this.eventListWP.map((event, index) => {
        const showFull =
            Array.isArray(this.isFullEvent) &&
            this.isFullEvent.length > 0 &&
            this.isFullEvent[0].index === index &&
            this.isFullEvent[0].isFull;

        const columnClass = event.EVT.Picture__c ? 'col-8' : 'col-12';

        return {
    ...event,
    EVT: event.EVT,
    showFull,
    columnClass,
    index,
    url: `/lightning/r/Event/${event.EVT.Id}/view`
};
    });
}



    connectedCallback() {
        this.getEventList();
        if (this.eventId) {
            this.getAllEventDetails(this.eventId);
            this.fetchAllDays();
        }
        Promise.all([

                loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/main.css'),

                loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/css/font-awesome.css'),

                loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/line-icons.css'),

                loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/css/bootstrap.css')

                // loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/js/bootstrap.min.js')

            ])

.then(() => {


                })

                .catch(error => {


                });
    }

    calculateQuantity() {
        this.calculatedQuantity = parseInt(this.regQuantity, 10) + 1;
    }

    changeView(event) {
        const view = event.currentTarget.dataset.tab;
        if (view !== this.view) {
            this.view = view;
        }
    }

    async searchEvent(event) {
        const timeLine = event.currentTarget.dataset.val;
        if (this.activeEventType !== timeLine) {
            switch (timeLine) {
                case 'today':
                    this.eventListWP = this.todayEventListWP;
                    break;
                case 'thisWeek':
                    this.eventListWP = this.thisWeekEventListWP;
                    break;
                case 'nextWeek':
                    this.eventListWP = this.nextWeekEventListWP;
                    break;
                case 'future':
                    this.eventListWP = this.futureEventListWP;
                    break;
                default:
                    this.showToast('Error', 'Invalid Event Timeline.', 'error');
                    setTimeout(() => {
                        this.errorMessage = '';
                    }, 5000);
            }
            this.activeEventType = timeLine;
        }
    }

    async printEvents(event) {
        const value = event.currentTarget.dataset.value;
        let events = [];
        switch (value) {
            case 'today':
                events = this.todayEventListWP;
                break;
            case 'thisWeek':
                events = this.thisWeekEventListWP;
                break;
            case 'nextWeek':
                events = this.nextWeekEventListWP;
                break;
            case 'future':
                events = this.futureEventListWP;
                break;
            default:
                events = this.fullEventListWP;
        }
        if (events.length > 0) {
            this.dispatchEvent(new CustomEvent('navigate', {
                detail: {
                    component: 'c-qrCodePrinter',
                    attributes: { events, type: 'Event' }
                }
            }));
        }
    }
handleLocationChange(event) {
    this.filterLocation = event.target.value;
    this.handleFilterEvents(); // Optional: only call if you want to filter immediately
}

handleTypeChange(event) {
    this.filterType = event.target.value;
    this.handleFilterEvents(); // Optional: only call if you want to filter immediately
}
    async handleFilterEventsByName(event) {
        //if (event.keyCode === 13 || !this.filterName) {
       //     await this.handleFilterEvents();
       // }
       this.filterName = event.target.value; // 🔥 THIS is what updates the variable!

    if (event.type === 'change') {
        await this.handleFilterEvents(); // run on blur/change
    } else if (event.type === 'keyup' && event.keyCode === 13) {
        await this.handleFilterEvents(); // run when Enter is pressed
    }
    }

    async handleFilterEvents() {
        this.isLoading = true;
        try {
            const result = await getEventList({
                eventName: this.filterName,
                eventLocation: this.filterLocation,
                eventType: this.filterType
            });
            this.changefiltervalues=false;
            this.processEventList(result);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    closeError() {
        this.errorMessage = '';
        this.successMessage = '';
    }

    async selectEvent(event) {
        this.isLoading = true;
    try {

        const eventIndex = event.currentTarget.dataset.index;
        const events = this.eventListWithExtras;
        if (events[eventIndex].EVT.Available_Registrations__c > 0) {
            this.event = events[eventIndex].EVT;
            this.eventId = events[eventIndex].EVT.Id;
            let selQty = 0;
            if (events[eventIndex].EVT.Maximum_Quantity_Select__c) {
                selQty = Math.min(
                    events[eventIndex].EVT.Available_Registrations__c,
                    events[eventIndex].EVT.Maximum_Quantity_Select__c
                );
                this.quantityList = Array.from({ length: selQty }, (_, i) => ({
                    class: 'optionClass',
                    label: (i + 1).toString(),
                    value: i
                }));
            }
            this.location = {
                Name: events[eventIndex].EVT.Event_Location__r.Name,
                Address__c: events[eventIndex].EVT.Event_Location__r.Address__c,
                City__c: events[eventIndex].EVT.Event_Location__r.City__c,
                Province_State__c: events[eventIndex].EVT.Event_Location__r.Province_State__c,
                Zip_Code__c: events[eventIndex].EVT.Event_Location__r.Zip_Code__c,
                Country__c: events[eventIndex].EVT.Event_Location__r.Country__c
            };
            this.regCheckIn = events[eventIndex].EVT.Instant_CheckIn__c;
            this.disableNext = true;
            if (this.event.Allow_Guest_Registrations__c) {
                this.disableForm = false;
            }
            await this.getAllEventDetails(this.eventId);
            await this.fetchAllDays();
        } else {
            this.showToast('Error', 'This Event Registrations are full.', 'error');
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
        this.isLoading = false;
    }catch(error){
         this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
    }
}

    async selectSchedule(event) {
        const index = event.currentTarget.dataset.index;
        const type = event.currentTarget.dataset.type;
        const dateColumnList = [...this.newDateColumnList];
        this.startdateReg=dateColumnList[index].AvailableDate1;
        if (dateColumnList[index].Zone) {
    // Slot-based → use duration
    this.showDate = dateColumnList[index].duration;
    this.isSlot=true;
   this.location = { ...dateColumnList[index].Zone.Event_Zone_Location__r };
} else {
    // Non-slot → use AvailableDate1
    this.showDate = dateColumnList[index].AvailableDate1;
    this.isSlot=false;
        this.location = { ...dateColumnList[index].Event.Event_Location__r };
}
        if (dateColumnList[index].AvailableQuantity > 0) {
            this.isLoading = true;
            if (!dateColumnList[index].isSelect) {
                if (type === 'singleSelect') {
                    dateColumnList.forEach(slot => (slot.isSelect = false));
                }
                dateColumnList[index].isSelect = true;
                this.disableNext = false;
            } else if (type !== 'singleSelect') {
                dateColumnList[index].isSelect = false;
                this.disableNext = !dateColumnList.some(slot => slot.isSelect);
            }
            this.newDateColumnList = dateColumnList;
            if (type === 'singleSelect') {
                this.reserveReg();
            }
            this.isLoading = false;
        }
    }

    reserveReg() {
        this.selectedSchedules = this.newDateColumnList.filter(slot => slot.isSelect);
        this.showEvtDetails = true;
    }

    goHome() {
        this.eventId = '';
        this.event = { sobjectType: 'Event__c' };
        this.showEvtDetails = false;
        this.container = [];
        this.newDateColumnList = [];
        this.newRegistrations = [];
        this.searchClientString = '';
        this.bookingType = 'group';
        this.createReg = { sobjectType: 'Registration__c' };
        this.result = [];
        this.resultReg = { sobjectType: 'Registration__c' };
        this.loopValidation = false;
        this.bookingSuccess = false;
        this.regQuantity = 0;
    }

    /*async changeDcLOC() {
        this.isLoading = true;
        const dcList = this.container.DateColumnList || [];
        this.newDateColumnList = dcList.filter(slot => slot.Zone?.Id === this.selectedDcLOC);

        this.isLoading = false;
    }*/
    async changeDcLOC(event) {
    this.selectedDcLOC = event.detail.value; // location id
    this.isLoading = true;

    const dcList = this.container.DateColumnList || [];
    this.newDateColumnList = dcList.filter(
        slot => slot.Zone?.Event_Zone_Location__c === this.selectedDcLOC
    );



    this.isLoading = false;
}

    changeBookType(event) {
        const type = event.currentTarget.dataset.tab;
        if (type !== this.bookingType) {
            this.bookingType = type;
            this.changeRegQty();
        }
    }

    clearSearch() {
        this.srList = [];
        this.searchClientString = '';
        this.createReg.Customer_Name__c = '';
        this.createReg.Customer_Lastname__c = '';
        this.createReg.Customer_Email__c = '';
        this.createReg.Customer_Contact__c = '';
        if (!this.event.Allow_Guest_Registrations__c) {
            this.disableForm = true;
        }
    }
    handleClientSearch(event) {
    this.searchClientString = event.target.value;
    this.displayRecords();
}

    async displayRecords() {
        /*if (!this.searchClientString) {
            this.clearSearch();
            return;
        }*/
        try {
            const result = await getSearchRecords({ searchString: this.searchClientString });
            this.srList = result;
            if (result?.length > 0) {
                this.showSearchPanel = true;
            }
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    setRecord(event) {
        const index = event.currentTarget.dataset.index;
        const record = this.srList[index];
        this.createReg.Contact__c = record.Id;
        this.searchClientString = record.Name;
        this.showSearchPanel = false;
        const nameArray = record.Name.split(' ');
        if (nameArray.length === 1) {
            this.createReg.Customer_Lastname__c = nameArray[0];
        } else if (nameArray.length > 1) {
            this.createReg.Customer_Name__c = nameArray[0];
            this.createReg.Customer_Lastname__c = nameArray[1];
        }
        if (record.Email) {
            this.createReg.Customer_Email__c = record.Email;
        }
        if (record.Phone) {
            this.createReg.Customer_Contact__c = record.Phone;
        }
        this.disableForm = false;
    }

    closeSearchPanel() {
        this.showSearchPanel = false;
    }

    get todaysEventsLabel() {
    return `Today's Events ${this.todaysEvents || 0}`;
        }

        get thisWeeksEventsLabel() {
            return `This Week Events ${this.thisWeeksEvents || 0}`;
        }

        get nextWeeksEventsLabel() {
            return `Next Week Events ${this.nextWeeksEvents || 0}`;
        }

        get futureEventsLabel() {
            return `Future Events ${this.futureEvents || 0}`;
        }

    changeRegQty() {
        let regs = [];
        const count = this.regQuantity;
        if (this.bookingType === 'individual') {
            regs = Array(count).fill().map(() => ({ sobjectType: 'Registration__c' }));
            this.newRegistrations = regs;
        } else if (this.bookingType === 'group') {
            this.createReg.Number_of_other_persons__c = count;
            this.newRegistrations = [];
        }
        this.loopValidation = false;
    }

    goToSchedules() {
        this.showEvtDetails = false;
        this.newDateColumnList.forEach(slot => (slot.isSelect = false));
        this.newRegistrations = [];
        this.searchClientString = '';
        this.bookingType = 'group';
        this.createReg = { sobjectType: 'Registration__c' };
        this.regQuantity = 0;
        this.loopValidation = false;
    }

    async createRegistrations(event) {
        const type = event.target.name;
        const pErrors = this.validateParentRegistrations();
        const cErrors = this.regQuantity > 0 && this.bookingType === 'individual' ?
            this.validateChildRegistrations() : true;
        if (pErrors && cErrors) {
            try {
                const schedules = this.selectedSchedules || [];
                const childRegs = this.newRegistrations;
                const parentRegistrations = [];
                const childRegistrations = [];
                const eventId = this.eventId;
                const event = this.event;
                const clientReg = this.createReg;

                if (schedules.length > 0) {
                    schedules.forEach(schedule => {
                        const reg = this.createRegistrationRecord(schedule, clientReg, eventId, event);
                        parentRegistrations.push(reg);
                        childRegs.forEach(child => {
                            const childReg = this.createChildRegistrationRecord(schedule, child, clientReg, eventId, event);
                            childRegistrations.push(childReg);
                        });
                    });
                } else {
                    const reg = this.createRegistrationRecord(null, clientReg, eventId, event);
                    parentRegistrations.push(reg);
                    childRegs.forEach(child => {
                        const childReg = this.createChildRegistrationRecord(null, child, clientReg, eventId, event);
                        childRegistrations.push(childReg);
                    });
                }

                if (parentRegistrations.length > 0) {
                    await this.finishBooking(parentRegistrations, childRegistrations, type);
                }
            } catch (error) {
                console.error('Error:', error);
                this.showToast('Error', error.message, 'error');
            }
        }
    }

    createRegistrationRecord(schedule, clientReg, eventId, event) {
        const reg = {
            sobjectType: 'Registration__c',
            Event__c: eventId,
            Registration_Type__c: 'Online',
            Status__c: this.regCheckIn ? 'Checked In' : 'Booked',
            Customer_Status__c: this.regCheckIn ? 'Attended' : 'Not Attended',
            Check_In__c: this.regCheckIn,
            Contact__c: clientReg.Contact__c,
            Customer_Name__c: clientReg.Customer_Name__c,
            Customer_Lastname__c: clientReg.Customer_Lastname__c,
            Customer_Email__c: clientReg.Customer_Email__c,
            Customer_Contact__c: clientReg.Customer_Contact__c,
            Number_of_other_persons__c: clientReg.Number_of_other_persons__c || 0
        };
        if (schedule?.Zone?.Id) {
            reg.Event_Zone__c = schedule.Zone.Id;
            reg.Registration_Time__c = schedule.AvailableDate1;
            reg.Registration_End_Time__c = schedule.Zone.End_Date__c;
            reg.End_Time__c = schedule.Zone.End_Date__c;
            reg.Expert_Location__c = schedule.Zone.Event_Zone_Location__c;
        } else {
            reg.Registration_Time__c = this.startdateReg;
            //reg.Registration_Time__c = event.Start_Date__c;
            reg.Registration_End_Time__c = event.End_Date__c;
            reg.End_Time__c = event.End_Date__c;
            reg.Expert_Location__c = event.Event_Location__c;
        }
        return reg;
    }

    createChildRegistrationRecord(schedule, childReg, clientReg, eventId, event) {
        const reg = {
            sobjectType: 'Registration__c',
            Event__c: eventId,
            Registration_Type__c: 'Online',
            Status__c: this.regCheckIn ? 'Checked In' : 'Booked',
            Customer_Status__c: this.regCheckIn ? 'Attended' : 'Not Attended',
            Check_In__c: this.regCheckIn,
            Contact__c: clientReg.Contact__c,
            Customer_Name__c: childReg.Customer_Name__c,
            Customer_Lastname__c: childReg.Customer_Lastname__c,
            Customer_Email__c: childReg.Customer_Email__c,
            Customer_Contact__c: childReg.Customer_Contact__c
        };
        if (schedule?.Zone?.Id) {
            reg.Event_Zone__c = schedule.Zone.Id;
            reg.Registration_Time__c = schedule.AvailableDate1;
            reg.Registration_End_Time__c = schedule.Zone.End_Date__c;
            reg.End_Time__c = schedule.Zone.End_Date__c;
            reg.Expert_Location__c = schedule.Zone.Event_Zone_Location__c;
        } else {
            reg.Registration_Time__c = event.Start_Date__c;
            reg.Registration_End_Time__c = event.End_Date__c;
            reg.End_Time__c = event.End_Date__c;
            reg.Expert_Location__c = event.Event_Location__c;
        }
        return reg;
    }

    async getEventList() {
        this.isLoading = true;
        try {
            const result = await getEventList({
                eventName: '',
                eventLocation: '',
                eventType: ''
            });
            this.processEventList(result);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }
    // JS
get eventListWithIndex() {
    return (this.eventListWP || []).map((item, index) => {
        return {
            ...item,
            displayIndex: index + 1,
            url: `/lightning/r/Event/${item.EVT.Id}/view`
        };
    });
}
get startDateFormatted() {
    return new Intl.DateTimeFormat('en-US', {
        day: '2-digit', month: 'short', year: 'numeric'
    }).format(new Date(this.startdateReg));
}


    processEventList(result) {
        this.eventListWP = this.activeEventType === 'today' ? result.todaysEvtList :
                          this.activeEventType === 'thisWeek' ? result.thisWeeksEvtList :
                          this.activeEventType === 'nextWeek' ? result.nextWeeksEvtList :
                          this.activeEventType === 'future' ? result.futureEvtList : [];
        this.todayEventListWP = result.todaysEvtList;
        this.thisWeekEventListWP = result.thisWeeksEvtList;
        this.nextWeekEventListWP = result.nextWeeksEvtList;
        this.futureEventListWP = result.futureEvtList;
        this.fullEventListWP = result.EvtList;
        this.todaysEvents = result.todaysEvents;
        this.thisWeeksEvents = result.thisWeeksEvents;
        this.nextWeeksEvents = result.nextWeeksEvents;
        this.futureEvents = result.futureEvents;

        const rawEventList=this.eventListWP ;
this.eventListWP = rawEventList.map((item, index) => {
    return {
        ...item,
        displayIndex: index + 1,
        url: `/lightning/r/Event/${item.EVT.Id}/view`
    };
});

        const locations = [{ class: 'optionClass', label: '--All Locations--', value: '' }];
        const types = [{ class: 'optionClass', label: '--All Types--', value: '' }];
        const locationSet = new Set();
        const typesSet = new Set();

        result.EvtList.forEach(item => {
            if (item.EVT.Event_Location__c && !locationSet.has(item.EVT.Event_Location__c)) {
                locationSet.add(item.EVT.Event_Location__c);
                locations.push({
                    class: 'optionClass',
                    label: item.EVT.Event_Location__r.Name,
                    value: item.EVT.Event_Location__c
                });
            }
            if (item.EVT.Event_Type__c && !typesSet.has(item.EVT.Event_Type__c)) {
                typesSet.add(item.EVT.Event_Type__c);
                types.push({
                    class: 'optionClass',
                    label: item.EVT.Event_Type__c,
                    value: item.EVT.Event_Type__c
                });
            }
        });
        if(this.changefiltervalues == true){
        this.locationList = locations;
        this.typeOfEventList = types;
        }
        this.isLoading = false;
    }

    async fetchAllDays() {
        this.isLoading = true;
        try {
            const result = await getAllDaysCon({
                EventId: this.eventId,
                RegId: this.rId
            });
            this.container = result;
            const dcList = result.DateColumnList || [];
            this.mainDateColumnList = dcList;
            this.newDateColumnList = dcList;
            const LocOptions = [];
            const locSet = new Set();
           /* dcList.forEach(item => {
                if (item.Zone?.Id && item.Zone.Event_Zone_Location__c && !locSet.has(item.Zone.Id)) {
                    locOptions.push({
                        class: 'optionClass',
                        label: item.Zone.Event_Zone_Location__r.Name,
                        id: item.Zone.Id
                    });
                    locSet.add(item.Zone.Id);
                }
            });
            this.locOptions = locOptions;*/
            dcList.forEach(item => {
    if (
        item.Zone?.Event_Zone_Location__c && // location id exists
        !locSet.has(item.Zone.Event_Zone_Location__c)
    ) {
        LocOptions.push({
            class: 'optionClass',
            label: item.Zone.Event_Zone_Location__r.Name, // location name
            value: item.Zone.Event_Zone_Location__c       // location id
        });
        locSet.add(item.Zone.Event_Zone_Location__c);
    }
});
this.LocOptions = LocOptions;

            if (dcList[0]?.Zone?.Id) {
                this.selectedDcLOC = dcList[0].Zone.Id;
                //await this.changeDcLOC();
            }


            this.isLoading = false;
            if (result.errMsg) {
                this.showToast('Error', result.errMsg, 'error');
                setTimeout(() => {
                    this.errorMessage = '';
                }, 5000);
            }
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    async getAllEventDetails(eventId) {
        this.isLoading = true;
        try {
            const result = await getEventDetail({
                eventId,
                zoneId: this.selectedDcLOC,
                LocId: this.event.Event_Location__c
            });
            this.agendaList = result.agendaList;
            this.sponsorList = result.sponsorshipList;
            this.speakerList = result.speakerList;
            this.location = result.Location;
            this.eventId = eventId;

            window.scrollTo({ top: 0, behavior: 'smooth' });
            this.isLoading = false;
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    async updateFullEvent(currentEvent, eIndex) {
        this.isLoading = true;
        try {
            await updateFilledEvent({ currentEvent: JSON.stringify(currentEvent) });
            await this.getEventList();
            if (this.view === 'grid' && this.eventListWP[eIndex].EVT.Id === currentEvent.Id) {
                this.isFullEvent = [{ index: parseInt(eIndex), isFull: true }];
                setTimeout(() => {
                    this.isFullEvent = [{ index: -1, isFull: false }];
                }, 5000);
            } else {
                this.showToast('Error', 'This Event Registrations are full.', 'error');
                setTimeout(() => {
                    this.errorMessage = '';
                }, 5000);
            }
            this.isLoading = false;
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    async finishBooking(parentRegs, childRegs, bookingMethod) {
        this.isLoading = true;
        try {
            const result = await createEventBookings({
                pRegs: JSON.stringify(parentRegs),
                cRegs: JSON.stringify(childRegs)
            });
            if (result.resultRegs.length > 0) {
                this.parentRegs = result.parentRegs;
                this.childRegs = result.childRegs;
                this.resultReg = result.resultRegs[0];
                if (result.resultRegs.length > 1) {
                    this.result = result.resultRegs;
                } else {
                    this.bookingSuccess = true;
                }
            } else {
                this.showToast('Error', 'Unexpected Error has occurred...', 'error');
            }
            this.isLoading = false;
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }
    }

    validateParentRegistrations() {
        let name = true;
        let email = true;
        let phone = true;
        const clientReg = this.createReg;

        if (!clientReg.Customer_Lastname__c) {
            const input = this.template.querySelector('[data-id="clientLN"]');
            input.classList.add('slds-has-error');
            name = false;
        }
        if (!clientReg.Customer_Email__c) {
            const input = this.template.querySelector('[data-id="clientE"]');
            input.classList.add('slds-has-error');
            email = false;
        }
        if (!clientReg.Customer_Contact__c) {
            const input = this.template.querySelector('[data-id="clientP"]');
            input.classList.add('slds-has-error');
            phone = false;
        }

        //! Commented by Aymaan Rule: no-dupe-else-if, else if (!name) is redundant, because the first condition (!name || !email || !phone) already covers !name.
        // let msg = '';
        // if (!name || !email || !phone) {
        //     msg = 'Required field missing - fields marked *';
        // } else if (!name) {
        //     msg = 'Required field missing - Please Enter Last Name.';
        // } else if (!email) {
        //     msg = 'Required field missing - Please Enter Email Id.';
        // } else if (!phone) {
        //     msg = 'Required field missing - Please Enter Phone No.';
        // }

        //! Fixed by Aymaan
        let msg = '';
        if (!name) {
            msg = 'Required field missing - Please Enter Last Name.';
        } else if (!email) {
            msg = 'Required field missing - Please Enter Email Id.';
        } else if (!phone) {
            msg = 'Required field missing - Please Enter Phone No.';
        }

        //! End fix

        if (msg) {
            this.showToast('Error', msg, 'error');
            setTimeout(() => {
                this.errorMessage = '';
            }, 5000);
        }

        return name && email && phone;
    }

    validateChildRegistrations() {
        if (this.newRegistrations.length > 0) {
            let name = true;
            let email = true;
            let phone = true;
            this.newRegistrations.forEach((reg, index) => {
                if (!reg.Customer_Lastname__c) {
                    this.template.querySelector(`[data-id="childLN${index}"]`).classList.add('slds-has-error');
                    name = false;
                }
                if (!reg.Customer_Email__c) {
                    this.template.querySelector(`[data-id="childE${index}"]`).classList.add('slds-has-error');
                    email = false;
                }
                if (!reg.Customer_Contact__c) {
                    this.template.querySelector(`[data-id="childP${index}"]`).classList.add('slds-has-error');
                    phone = false;
                }
            });
            if (!name || !email || !phone) {
                this.loopValidation = true;
                this.showToast('Error', 'Required field missing - fields marked *', 'error');
                setTimeout(() => {
                    this.errorMessage = '';
                }, 5000);
            }
            return name && email && phone;
        }
        return true;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleInputChange(event) {

        const field = event.target.dataset.id;
        if (field.startsWith('child')) {
            const index = parseInt(field.match(/\d+/)[0], 10);
            const fieldName = field.replace(/\d+/, '');
            this.newRegistrations[index][fieldName] = event.target.value;
        } else {
            this.createReg[field] = event.target.value;
        }
    }
    /* handleInputChange(event) {
      const fieldName = event.target.value;
    }*/

}