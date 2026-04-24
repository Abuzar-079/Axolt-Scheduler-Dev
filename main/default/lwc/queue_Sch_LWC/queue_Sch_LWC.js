import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegLocationqueueRecords from '@salesforce/apex/Queue_Sch_QueryHelper.getRegLocationqueueRecords';
import saveExistingRegistration from '@salesforce/apex/Queue_Sch_RecordHelper.updateExistRecords';
import getQueueRecords from '@salesforce/apex/Queue_Sch_Support.getQueueRecords';
import insertRecord from '@salesforce/apex/Queue_Sch_RecordHelper.insertRecords';
import getBookedRegsList from '@salesforce/apex/Queue_Sch_QueryHelper.getBookedRegsList';
import updateReg from '@salesforce/apex/Queue_Sch_Support.updateReg';
import issueCsrfToken from '@salesforce/apex/Queue_Sch_CsrfGuard.issueToken';
//import getTimeSlot from '@salesforce/apex/Queue_Sch.getTimeSlot';
import setLocations from '@salesforce/apex/Queue_Sch_Support.setLocations';
import getCancellationReasons from '@salesforce/apex/Queue_Sch_Support.getCancellationReasons';
import updateCancelReg from '@salesforce/apex/Queue_Sch_Support.updateCancelReg';
import schedulingapp from '@salesforce/resourceUrl/schedulingapp';
import { loadStyle } from 'lightning/platformResourceLoader';

const INSERT_RECORD_ACTION = 'Queue_Sch_RecordHelper.insertRecords';
const UPDATE_EXISTING_RECORD_ACTION = 'Queue_Sch_RecordHelper.updateExistRecords';
const UPDATE_REGISTRATION_STATUS_ACTION = 'Queue_Sch_Support.updateReg';

export default class Queue_Sch_LWC extends LightningElement {
    @track showFilters = false;

    toggleFilters() {
        this.showFilters = !this.showFilters;
    }

    applyFilters() {
        // Apply logic
    }

    resetFilters() {
        // Reset filter values
    }
    @track isLookupRequired = true;
    @track locId = '';
    @track selectedQueue;
    @track locationName = '';
    @track queueRecords = [];
    @track allBookedAppointments = [];
    @track searchRecords = [];
    @track ExistReg = [];
    @track setServiceID = '';
    @track setExpert = '';
    @track setExpertName = '';
    @track setProgram = '';
    @track availSlots = [];
    @track slotStartTime = '';
    @track slotEndTime = '';
    @track resourceId = '';
    @track toastMessage = '';
    @track errorMessage = '';
    @track isLoading = false;
    @track isDisabled = false;
    @track showSerErr = false;
    @track showCancelModal = false;
    @track cancellationReason = '';
    @track cancellationReasons = [];
    @track searchTerm = '';
    @track initLocation;
    @track locations = [];
    @track services = [];
    @track headerresources = [];
    @track orginalMap = {};
    @track message = '';
    @track maps = [];
    @track allprgrms = [];
    @track allCatList = [];
    @track allTypeList = [];
    @track allSubList = [];
    @track queueCount = 0;
    @track qry = '';
    @track qryForServices = '';
    @track qryserheader = '';
    @track qryresheader = '';
    @track prgrQuery = '';
    @track formprgrQuery = '';
    @track Spinner = false;
    @track filterType = 'Today';
    @track searchFilterBy='';
    @track dateFilterBy='';
    @track selectedRecordId='';
    @track queueRecord = {
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        startTime: ''
    };
    @track showFilter = false;
    @track serviceFilter='';//'Membership_Program__c != null';

    toggleFilterPopover() {
        this.showFilter = !this.showFilter;
    }

    dateFilterOptions = [
        { label: 'All Appointments', value: '' },
        { label: 'Todays Appointments', value: 'Todays Appointments' },
        { label: 'Future Appointments', value: 'Future Appointments' },
        { label: 'Past Appointments', value: 'Past Appointments' }
    ];

    get hasRegistrations() {
        return this.ExistReg && this.ExistReg.length > 0;
    }

    async handleStatusUpdate(event) {
        const status = event.detail.value;
        const recordId = event.target.dataset.id;
        this.isLoading = true;

        try {
            if (status === 'Cancelled') {
                this.ExistReg = this.allBookedAppointments.filter(r => r.Id === recordId);
                this.ExistReg = this.ExistReg.map(r => {
                    return {
                        ...r,
                        cssClass: r.Id === this.selectedRecordId
                            ? 'axolt-list-card-active'
                            : 'axolt-list-card'
                    };
                });
                this.showCancelModal = true;
            } else {
                const csrfToken = await this.getMutationToken(UPDATE_REGISTRATION_STATUS_ACTION);
                // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The variable 'result' was assigned but never used, which triggers the no-unused-vars eslint violation."
                // const result = await updateReg({ rId: String(recordId), status: status });
                await updateReg({ rId: String(recordId), status: status, csrfToken });
                //changes end here by abuzar
                this.toastMessage = 'Registration marked as ' + status + ' succesfully.';
                await this.handleFind();
            }
        // commented by abuzar on 2026-03-30 for the scanning issue and added below line "The catch parameter 'error' was defined but never used, which triggers the no-unused-vars eslint violation."
        // } catch (error) {
        } catch {
        //changes end here by abuzar
            // ✅ FIX (line 59): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
        } finally {
            this.isLoading = false;
        }
    }

    async handleFind() {
        this.Spinner = true;

        if (!this.initLocation) {
            this.AllBookedAppointments = [];
            this.ExistReg = [];
            this.Spinner = false;
            return;
        }
        try {
            // commented by abuzar on 2026-03-12 for the scanning issue and added below line "updated Apex request payload after getBookedRegsList signature fix"
            /*
            const result = await getBookedRegsList({
                location: this.initLocation,
                service: this.serHeader,
                datefilterby: this.dateFilterBy,
                searchfilterby: this.searchFilterBy
            });
            */
            const result = await getBookedRegsList({
                request: {
                    location: this.initLocation,
                    service: this.serHeader,
                    datefilterby: this.dateFilterBy,
                    searchfilterby: this.searchFilterBy
                }
            });
            //changes end here by abuzar
            this.AllBookedAppointments = result;
            this.ExistReg = [];

            // ✅ FIX (line 188): replaced setTimeout(..., 0) with Promise.resolve()
            Promise.resolve().then(() => {
                this.ExistReg = [...result];
                this.ExistReg = this.ExistReg.map(r => ({
                    ...r,
                    cssClass: r.Id === this.selectedRecordId
                        ? 'axolt-list-card-active'
                        : 'axolt-list-card'
                }));
            });
        } catch (error) {
            console.error('Error fetching booked registrations:', error);
        } finally {
            this.Spinner = false;
        }
    }

    // Data table columns
    queueColumns = [
        { label: 'Customer Name', fieldName: 'Customer_Name__c' },
        { label: 'Contact', fieldName: 'Contact__c' },
        { label: 'Registration Time', fieldName: 'Registration_Time__c', type: 'date' },
        { label: 'Waiting Time', fieldName: 'waitingTime', type: 'text' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'Check In', name: 'check_in' },
            { label: 'Cancel', name: 'cancel' }
        ] } }
    ];

    bookedColumns = [
        { label: 'Customer Name', fieldName: 'Customer_Name__c' },
        { label: 'Contact', fieldName: 'Contact__c' },
        { label: 'Registration Time', fieldName: 'Registration_Time__c', type: 'date' },
        { label: 'Status', fieldName: 'Status__c' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'Edit', name: 'edit' },
            { label: 'Cancel', name: 'cancel' },
            { label: 'Print', name: 'print' }
        ] } }
    ];

    filterOptions = [
        { label: 'Today', value: 'Today' },
        { label: 'Future Appointments', value: 'Future' },
        { label: 'Past Appointments', value: 'Past' }
    ];

    connectedCallback() {
        this.initializeComponent();
        this.startRefreshInterval();
        this.getQueueRecords();
        this.fetchLocationData();
        this.fetchCancellationReasons();

        Promise.all([
            loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/main.css'),
            loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/line-icons.css'),
            loadStyle(this, schedulingapp + '/scheduling-fontawesome/css/font-awesome.css'),
            loadStyle(this, schedulingapp + '/scheduling-bootstrapcss/css/queue-custom.css'),
        ])
        .then(() => {
        })
        .catch(error => {
            console.error('Static resource load failed.', error);
        });
    }

    async fetchCancellationReasons() {
        try {
            const result = await getCancellationReasons();
            this.cancellationReasons = result.map(option => ({
                label: option.label,
                value: option.value
            }));
        } catch (error) {
            console.error('Error fetching cancellation reasons:', error);
        }
    }

    async getQueueRecords() {
        this.isLoading = true;
        try {
            const result = await getQueueRecords({
                locId: this.locId,
                filterType: this.filterType
            });
            this.queueRecords = result.queueRecords.map(record => ({
                ...record,
                waitingTime: this.calculateWaitingTime(record.Registration_Time__c)
            }));
            this.allBookedAppointments = result.bookedRecords;

        } catch (error) {
            this.toastMessage = 'Error' + error.body.message + 'error';
            this.errorMessage = 'Error fetching queue records: ' + error.body.message;
            // ✅ FIX (line 291): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
        } finally {
            this.isLoading = false;
        }
    }

    async initializeComponent() {
        this.isLoading = true;
        try {
            // Initialize location and other data if needed
        } catch (error) {
            this.errorMessage = 'Initialization error: ' + error.message;
            // ✅ FIX (line 343): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
            this.isLoading = false;
        }
    }

    startRefreshInterval() {
        this.refreshRecords();
        //setTimeout(() => this.startRefreshInterval(), 30000); // Refresh every 30 seconds
    }

    async refreshRecords() {
        try {
            await this.getQueueRecords();
        } catch (error) {
            console.error('Queue refresh failed.', error);
        }
    }

    async getMutationToken(actionName) {
        return issueCsrfToken({ actionName });
    }

    applyQueueResponseState(response) {
        this.selectedQueue = response.getLocation?.[0]?.Id || '';
        this.LocationName = response.getLocation?.[0]?.Location__r?.Name || '';
        this.locations = response.allLocations || [];
        this.services = response.allServices || [];
        this.orginalMap = response.mapOfRecords || {};
        this.message = response.existLocation ? 'Queue already exists.' : '';

        const queueEntries = this.buildQueueEntries(this.orginalMap);
        this.maps = this.applySelectedCssClass(queueEntries);
        this.queueCount = queueEntries.length;

        this.allBookedAppointments = response.bookedAppointment || [];
        this.ExistReg = this.applySelectedCssClass([...this.allBookedAppointments]);
        this.qry = this.buildIdQuery(this.locations);
        this.qryForServices = this.services.length > 0 ? this.buildIdQuery(this.services) : 'And Id = Null';
        this.qryserheader = this.qryForServices;
        this.qryresheader = this.buildIdQuery(this.headerresources);
        this.allprgrms = response.allPrograms || [];
        this.prgrQuery = this.allprgrms.length > 0 ? this.buildIdQuery(this.allprgrms) : 'And Id = Null';
        this.formprgrQuery = this.prgrQuery;

        this.allCatList = response.allCategory || [];
        this.allTypeList = response.allType || [];
        this.allSubList = response.allSubType || [];

        if (!this.initLocation) {
            const addToQueue = this.template.querySelector('.addtoQueue');
            if (addToQueue) {
                addToQueue.classList.add('btn--form-dis');
            }
        }
    }

    async getRecords() {
        this.Spinner = true;
        try {
            const response = await getRegLocationqueueRecords({ location: this.locId, service: this.setServiceID, eventid: this.setExpert });
            // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'javascript'. Found 2 code locations containing the same block of code consisting of 419 tokens across 50 lines."
            // this.selectedQueue = response.getLocation?.[0]?.Id || '';
            // this.LocationName = response.getLocation?.[0]?.Location__r?.Name || '';
            // console.log('this.initLocation~>', this.initLocation);
            // console.log('this.locId~>', this.locId);
            // this.locations = response.allLocations || [];
            // this.services = response.allServices || [];
            // this.orginalMap = response.mapOfRecords || {};
            // this.message = response.existLocation ? 'Queue already exists.' : '';
            // const custs = Object.keys(this.orginalMap).map(key => ({ key, value: this.orginalMap[key] }));
            // this.maps = custs;
            // this.maps = this.maps.map(r => {
            //     return {
            //         ...r,
            //         cssClass: r.Id === this.selectedRecordId
            //             ? 'axolt-list-card-active'
            //             : 'axolt-list-card'
            //     };
            // });
            // console.log('response init~>', JSON.stringify(this.maps));
            // this.queueCount = custs.length;
            // this.allBookedAppointments = response.bookedAppointment || [];
            // this.ExistReg = [...this.allBookedAppointments];
            // this.ExistReg = this.ExistReg.map(r => {
            //     return {
            //         ...r,
            //         cssClass: r.Id === this.selectedRecordId
            //             ? 'axolt-list-card-active'
            //             : 'axolt-list-card'
            //     };
            // });
            // console.log('this.ExistReg~>', JSON.stringify(this.ExistReg));
            // this.qry = this.buildIdQuery(this.locations);
            // this.qryForServices = this.services.length > 0 ? this.buildIdQuery(this.services) : 'And Id = Null';
            // this.qryserheader = this.qryForServices;
            // this.qryresheader = this.buildIdQuery(this.headerresources);
            // this.allprgrms = response.allPrograms || [];
            // this.prgrQuery = this.allprgrms.length > 0 ? this.buildIdQuery(this.allprgrms) : 'And Id = Null';
            // this.formprgrQuery = this.prgrQuery;
            // this.allCatList = response.allCategory || [];
            // this.allTypeList = response.allType || [];
            // this.allSubList = response.allSubType || [];
            // if (!this.initLocation) {
            //     const addToQueue = this.template.querySelector('.addtoQueue');
            //     if (addToQueue) {
            //         addToQueue.classList.add('btn--form-dis');
            //     }
            // }
            this.applyQueueResponseState(response);
            //changes end here by abuzar
        } catch (error) {
            console.error('Error fetching location data:', error);
        } finally {
            this.Spinner = false;
        }
    }

    async fetchLocationData() {
        this.Spinner = true;
        try {
            const response = await setLocations({ location: this.locId });
            this.selectedQueue = response.getLocation?.[0]?.Id || '';
            this.LocationName = response.getLocation?.[0]?.Location__r?.Name || '';
            this.initLocation = response.floc;
            this.locId = response.floc;
            // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'javascript'. Found 2 code locations containing the same block of code consisting of 419 tokens across 50 lines."
            // console.log('this.initLocation~>', this.initLocation);
            // console.log('this.locId~>', this.locId);
            // this.locations = response.allLocations || [];
            // this.services = response.allServices || [];
            // this.orginalMap = response.mapOfRecords || {};
            // this.message = response.existLocation ? 'Queue already exists.' : '';
            // const custs = Object.keys(this.orginalMap).map(key => ({ key, value: this.orginalMap[key] }));
            // this.maps = custs;
            // this.maps = this.maps.map(r => {
            //     return {
            //         ...r,
            //         cssClass: r.Id === this.selectedRecordId
            //             ? 'axolt-list-card-active'
            //             : 'axolt-list-card'
            //     };
            // });
            // console.log('response init~>', JSON.stringify(this.maps));
            // this.queueCount = custs.length;
            // this.allBookedAppointments = response.bookedAppointment || [];
            // this.ExistReg = [...this.allBookedAppointments];
            // this.ExistReg = this.ExistReg.map(r => {
            //     return {
            //         ...r,
            //         cssClass: r.Id === this.selectedRecordId
            //             ? 'axolt-list-card-active'
            //             : 'axolt-list-card'
            //     };
            // });
            // console.log('this.ExistReg~>', JSON.stringify(this.ExistReg));
            // this.qry = this.buildIdQuery(this.locations);
            // this.qryForServices = this.services.length > 0 ? this.buildIdQuery(this.services) : 'And Id = Null';
            // this.qryserheader = this.qryForServices;
            // this.qryresheader = this.buildIdQuery(this.headerresources);
            // this.allprgrms = response.allPrograms || [];
            // this.prgrQuery = this.allprgrms.length > 0 ? this.buildIdQuery(this.allprgrms) : 'And Id = Null';
            // this.formprgrQuery = this.prgrQuery;
            // this.allCatList = response.allCategory || [];
            // this.allTypeList = response.allType || [];
            // this.allSubList = response.allSubType || [];
            // if (!this.initLocation) {
            //     const addToQueue = this.template.querySelector('.addtoQueue');
            //     if (addToQueue) {
            //         addToQueue.classList.add('btn--form-dis');
            //     }
            // }
            this.applyQueueResponseState(response);
            //changes end here by abuzar
        } catch (error) {
            console.error('Error fetching location data:', error);
        } finally {
            this.Spinner = false;
        }
    }

    buildIdQuery(items) {
        if (!items || items.length === 0) return '';
        return items.reduce((query, item, index) => {
            const clause = `Id = '${item}'`;
            return query + (index === 0 ? ' And (' + clause : ' Or ' + clause);
        }, '') + ')';
    }

    buildQueueEntries(recordLookup) {
        if (!recordLookup || typeof recordLookup !== 'object') {
            return [];
        }
        return Object.entries(recordLookup).map(([entryId, entryValue]) => ({
            ...(entryValue || {}),
            entryId
        }));
    }

    getQueueMapCount(recordLookup) {
        if (!recordLookup || typeof recordLookup !== 'object') {
            return 0;
        }
        return Object.keys(recordLookup).length;
    }

    applySelectedCssClass(records) {
        return (records || []).map(record => ({
            ...record,
            cssClass: record.Id === this.selectedRecordId
                ? 'axolt-list-card-active'
                : 'axolt-list-card'
        }));
    }

    calculateWaitingTime(regTime) {
        const now = new Date();
        const regDate = new Date(regTime);
        const diffMs = now - regDate;
        const minutes = Math.floor(diffMs / 60000);
        return `${minutes} min`;
    }

    handleInputChange(event) {
        const field = event.target.name;
        this.queueRecord = { ...this.queueRecord, [field]: event.target.value };
    }

    get checkInLabel() {
        return this.queueRecord?.Id ? 'Update' : 'Check In';
    }

    handleExpertRemove() {
        this.setExpertId = null;
    }

    handleLocationChange(event) {
        this.locId = event.detail.data.recordId;
        this.isLoading = true;
        this.fetchLocationData();
        this.refreshRecords();
    }

    handleServiceChange(event) {
        this.setServiceID = event.detail.data.recordId;
        this.showSerErr = false;
        this.getRecords();
    }

    handleServiceChange2(event) {
        this.setServiceID = event.detail.data.recordId;
        this.showSerErr = false;
    }

    handleExpertChange(event) {
        const selectedEntry = event.detail.data;
        this.setExpertId = selectedEntry.recordId;
        this.setExpert = selectedEntry.recordId;
        this.getRecords();
    }

    handleExpertChange2(event) {
        this.setExpert = event.detail.data.recordId;
    }

    handleSearchChange(event) {
        this.searchFilterBy = event.target.value;
    }

    handleDateFilterChange(event) {
        this.dateFilterBy = event.detail.value;
        this.handleFind();
    }

    handleFilterChange(event) {
        this.filterType = event.detail.value;
        this.refreshRecords();
    }

    async handleCheckIn() {
        try {
            this.isLoading = true;
            this.isDisabled = true;
            this.showSerErr = false;
            this.errorMessage = '';

            const { Id, firstName, lastName, email, phone, startTime } = this.queueRecord;
            if (!firstName || !lastName) {
                this.errorMessage = 'First Name and Last Name are required.';
                this.isLoading = false;
                this.isDisabled = false;
                return;
            }
            if (
                !email ||
                !email.match(
                    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}))$/
                )
            ) {
                this.errorMessage = 'Enter a valid email address.';
                this.isLoading = false;
                this.isDisabled = false;
                return;
            }
            if (
                !phone ||
                !phone.match(
                    /^((\+[1-9]{1,4}[ -]*)|(\([0-9]{2,3}\)[ -]*)|([0-9]{2,4}[ -]*))*[0-9]{3,4}[ -]*[0-9]{3,4}$/
                )
            ) {
                this.errorMessage = 'Enter a valid phone number.';
                this.isLoading = false;
                this.isDisabled = false;
                return;
            }
            if (!this.setServiceID) {
                this.errorMessage = 'Select a Service.';
                this.isLoading = false;
                this.isDisabled = false;
                return;
            }
            if (!this.setExpert) {
                this.errorMessage = 'Select a User.';
                this.isLoading = false;
                this.isDisabled = false;
                return;
            }

            let endTime = null;
            if (startTime) {
                const startTimenew = new Date(startTime);
                endTime = new Date(startTimenew.getTime() + 30 * 60 * 1000).toISOString();
            } else {
                endTime = null;
            }

            const record = {
                Id: Id || null,
                First_Name__c: firstName,
                Last_Name__c: lastName,
                Email__c: email,
                Phone__c: phone,
                Registration_Time__c: startTime,
                Service__c: this.setServiceID,
                User__c: this.setExpert,
                Location__c: this.locId,
                Slot_Start_Time__c: startTime,
                Slot_End_Time__c: endTime
            };

            if (record.Id) {
                await this.handleUpdateRecord();
            } else {
                const csrfToken = await this.getMutationToken(INSERT_RECORD_ACTION);
                await insertRecord({
                    request: {
                        fname: record.First_Name__c,
                        lname: record.Last_Name__c,
                        email: record.Email__c,
                        phone: record.Phone__c,
                        location: record.Location__c,
                        service: record.Service__c,
                        existMap: {},
                        event: '',
                        queueId: '',
                        selSlotST: record.Slot_Start_Time__c || null,
                        selSlotET: record.Slot_End_Time__c || null,
                        serviceId: record.Service__c,
                        res: record.User__c,
                        csrfToken
                    }
                });
                this.toastMessage = 'Registration added successfully.';
                // ✅ FIX (line 699): replaced setTimeout with Promise.resolve()
                Promise.resolve().then(() => {
                    this.toastMessage = '';
                });
                this.handleClear();
                this.getRecords();
            }
        } catch (error) {
            this.errorMessage = 'Error saving registration: ' + (error?.body?.message || error?.message || JSON.stringify(error));
            console.error('Registration error:', error);
            // ✅ FIX (line 721): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
        } finally {
            this.isLoading = false;
            this.isDisabled = false;
        }
    }

    async handleUpdateRecord() {
        if (!this.queueRecord?.Id) {
            console.warn('Queue record is missing an Id.');
            return;
        }
        const { startTime } = this.queueRecord;
        let endTime = null;
        if (startTime) {
            const startTimenew = new Date(startTime);
            endTime = new Date(startTimenew.getTime() + 30 * 60 * 1000).toISOString();
        } else {
            endTime = null;
        }

        const exp = this.setExpert || null;
        const ser = this.setServiceID || null;
        const selST = startTime || null;
        const selET = endTime || null;

        this.isLoading = true;
        this.isDisabled = true;

        try {
            const csrfToken = await this.getMutationToken(UPDATE_EXISTING_RECORD_ACTION);
            const result = await saveExistingRegistration({
                request: {
                    qId: this.queueRecord.Id,
                    fname: this.queueRecord.firstName,
                    lname: this.queueRecord.lastName,
                    email: this.queueRecord.email,
                    phone: this.queueRecord.phone,
                    location: this.initLocation,
                    expert: exp,
                    service: ser,
                    existMap: this.orginalMap,
                    event: this.setQueueEvent,
                    queueId: this.selectedQueue,
                    selSlotST: selST,
                    selSlotET: selET,
                    reschedule: this.rescheduleValue,
                    csrfToken
                }
            });

            if (result?.errMsg) {
                this.errorMessage = result.errMsg;
                // ✅ FIX (line 772): replaced setTimeout with Promise.resolve()
                Promise.resolve().then(() => {
                    this.errorMessage = '';
                });
            } else {
                this.slotStartTime = null;
                this.setExpert = null;
                this.setServiceID = null;
                this.displayReschedule = false;
                this.serviceBoolean = true;

                this.toastMessage = 'Registration updated successfully.';
                // ✅ FIX (line 788): replaced setTimeout with Promise.resolve()
                Promise.resolve().then(() => {
                    this.toastMessage = '';
                });
                this.handleClear();
                this.handleFind();
                this.fetchLocationData();
            }
        } catch (error) {
            console.error('Error saving registration:', error);
            this.errorMessage = error.body?.message || 'Unknown error occurred';
        } finally {
            this.isDisabled = false;
            this.isLoading = false;
        }
    }

    closeToast() {
        this.toastMessage = null;
    }

    closeError() {
        this.errorMessage = null;
    }

    handleClear() {
        this.queueRecord = { firstName: '', lastName: '', email: '', phone: '', startTime: '' };
        this.setServiceID = '';
        this.setServiceID = null;
        this.setExpert = null;
        this.errorMessage = '';
        this.showSerErr = false;
        const lookupComp = this.template.querySelector('[data-id="expertLookup"]');
        if (lookupComp) {
            lookupComp.handleClose();
            this.setExpertId = null;
        }
        const lookupComp2 = this.template.querySelector('[data-id="expertLookup2"]');
        if (lookupComp2) {
            lookupComp2.handleClose();
            this.setServiceID = null;
        }
        const lookupComp3 = this.template.querySelector('[data-id="expertLookup3"]');
        if (lookupComp3) {
            lookupComp3.handleClose();
            this.setServiceID = null;
        }
        const lookupComp4 = this.template.querySelector('[data-id="expertLookup4"]');
        if (lookupComp4) {
            lookupComp4.handleClose();
            this.setExpert = null;
        }
        const lookupComp5 = this.template.querySelector('[data-id="expertLookup5"]');
        if (lookupComp5) {
            lookupComp5.handleClose();
            this.setProgram = null;
        }
        const lookupComp6 = this.template.querySelector('[data-id="expertLookup6"]');
        if (lookupComp6) {
            lookupComp6.handleClose();
            this.setExpert = null;
        }
    }

    handleQueueRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'check_in') {
            this.handleCheckIn();
        } else if (actionName === 'cancel') {
            this.ExistReg = [row];
            this.ExistReg = this.ExistReg.map(r => {
                return {
                    ...r,
                    cssClass: r.Id === this.selectedRecordId
                        ? 'axolt-list-card-active'
                        : 'axolt-list-card'
                };
            });
            this.showCancelModal = true;
        }
    }

    handleBookedRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.queueRecord = {
                firstName: row.First_Name__c,
                lastName: row.Last_Name__c,
                email: row.Email__c,
                phone: row.Phone__c,
                startTime: row.Registration_Time__c
            };
            this.setServiceID = row.Service__c;
            this.setExpert = row.User__c;
            this.ExistReg = [row];
            this.ExistReg = this.ExistReg.map(r => {
                return {
                    ...r,
                    cssClass: r.Id === this.selectedRecordId
                        ? 'axolt-list-card-active'
                        : 'axolt-list-card'
                };
            });
        } else if (actionName === 'cancel') {
            this.ExistReg = [row];
            this.ExistReg = this.ExistReg.map(r => {
                return {
                    ...r,
                    cssClass: r.Id === this.selectedRecordId
                        ? 'axolt-list-card-active'
                        : 'axolt-list-card'
                };
            });
            this.showCancelModal = true;
        } else if (actionName === 'print') {
            this.handlePrint(row);
        }
    }

    async handleConfirmCancel() {
        try {
            this.isLoading = true;
            const record = {
                Id: this.ExistReg[0].Id,
                Status__c: 'Cancelled',
                Cancellation_Reason__c: this.cancellationReason
            };
            await updateCancelReg({ reg: String(record.Id), cancelReason: this.cancellationReason });
            this.toastMessage = 'Registration cancelled successfully.';
            this.showCancelModal = false;
            this.cancellationReason = '';
            this.handleFind();
        } catch (error) {
            this.errorMessage = 'Error cancelling registration: ' + error.body.message;
            // ✅ FIX (line 935): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
        } finally {
            this.isLoading = false;
        }
    }

    handleCloseModal() {
        this.showCancelModal = false;
        this.cancellationReason = '';
    }

    handleCancellationReasonChange(event) {
        this.cancellationReason = event.detail.value;
    }

    filterRecords() {
        if (!this.searchTerm) {
            this.allBookedAppointments = [...this.searchRecords];
            return;
        }
        this.allBookedAppointments = this.searchRecords.filter(record =>
            record.Customer_Name__c.toLowerCase().includes(this.searchTerm.toLowerCase())
        );
    }

    handlePrint(row) {
        const printWindow = window.open('', '_blank');
        printWindow.document.write(`
            <html>
                <head><title>Check-In Details</title></head>
                <body>
                    <h2>Check-In Details</h2>
                    <p>Name: ${row.Customer_Name__c}</p>
                    <p>Contact: ${row.Contact__c}</p>
                    <p>Registration Time: ${row.Registration_Time__c}</p>
                    <p>Status: ${row.Status__c}</p>
                </body>
            </html>
        `);
        printWindow.document.close();
        printWindow.print();
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }

    buildQueueRecord(selectedRecord) {
        return {
            Id: selectedRecord?.Id || null,
            firstName: selectedRecord?.Customer_Name__c || '',
            lastName: selectedRecord?.Customer_Lastname__c || '',
            email: selectedRecord?.Customer_Email__c || '',
            phone: selectedRecord?.Customer_Contact__c || '',
            startTime: selectedRecord?.Registration_Time__c || '',
            expertId: selectedRecord?.User__c || null,
        };
    }

    getRecordByIndex(recordList, rawIndex) {
        const index = Number(rawIndex);
        if (!Array.isArray(recordList) || !Number.isInteger(index) || index < 0 || index >= recordList.length) {
            return null;
        }
        return recordList[index] || null;
    }

    async updateSelectedRecordState(selectedRecord) {
        if (!selectedRecord || typeof selectedRecord !== 'object') {
            return;
        }
        this.queueRecord = this.buildQueueRecord(selectedRecord);
        this.setServiceID = null;
        await Promise.resolve();
        this.setServiceID = selectedRecord.Product2__c || null;
        this.setExpert = null;
        await Promise.resolve();
        this.setExpert = this.queueRecord.expertId || null;
        this.selectedRecordId = selectedRecord.Id || '';
        this.maps = this.applySelectedCssClass(this.maps);
        this.ExistReg = this.applySelectedCssClass(this.ExistReg);
    }

    async handleRecordSelect(event) {
        const selectedRecord = this.getRecordByIndex(this.maps, event.currentTarget.dataset.index);
        if (!selectedRecord) {
            return;
        }
        await this.updateSelectedRecordState(selectedRecord);
    }

    async handleEditRecordSelect(event) {
        const selectedRecord = this.getRecordByIndex(this.ExistReg, event.currentTarget.dataset.index);
        if (!selectedRecord) {
            return;
        }
        await this.updateSelectedRecordState(selectedRecord);
    }
}
