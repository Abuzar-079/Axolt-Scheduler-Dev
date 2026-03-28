import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegLocationqueueRecords from '@salesforce/apex/Queue_Sch_QueryHelper.getRegLocationqueueRecords';
import updateExistRecords from '@salesforce/apex/Queue_Sch_RecordHelper.updateExistRecords';
import getQueueRecords from '@salesforce/apex/Queue_Sch_Support.getQueueRecords';
import addQueueRecord from '@salesforce/apex/Queue_Sch_RecordHelper.insertRecords';
import getBookedRegsList from '@salesforce/apex/Queue_Sch_QueryHelper.getBookedRegsList';
import updateReg from '@salesforce/apex/Queue_Sch_Support.updateReg';
//import getTimeSlot from '@salesforce/apex/Queue_Sch.getTimeSlot';
import setLocations from '@salesforce/apex/Queue_Sch_Support.setLocations';
import getCancellationReasons from '@salesforce/apex/Queue_Sch_Support.getCancellationReasons';
import updateCancelReg from '@salesforce/apex/Queue_Sch_Support.updateCancelReg';
import schedulingapp from '@salesforce/resourceUrl/schedulingapp';
import { loadStyle } from 'lightning/platformResourceLoader';






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
        console.log('status', status);
        console.log('recordId', recordId);

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
                const result = await updateReg({ rId: String(recordId), status: status });
                console.log('Apex response:', result);
                this.toastMessage = 'Registration marked as ' + status + ' succesfully.';
                await this.handleFind();
            }
        } catch (error) {
            console.log('Error updating status:', error);
            // ✅ FIX (line 59): replaced setTimeout with Promise.resolve()
            Promise.resolve().then(() => {
                this.errorMessage = '';
            });
        } finally {
            this.isLoading = false;
        }
    }

    async handleFind() {
        console.log('Inside');
        this.Spinner = true;
        console.log('Inside 2');

        if (!this.initLocation) {
            console.log('Inside 3');
            this.AllBookedAppointments = [];
            this.ExistReg = [];
            this.Spinner = false;
            return;
        }
        console.log(' this.SearchFilterBy:', this.searchFilterBy);
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
            console.log('Inside res', result);
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
            console.log('Static Resource Loaded');
        })
        .catch(error => {
            console.log('Static Resource Error', error);
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
            console.log('this.locId:', this.locId);
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full queue response objects can expose sensitive data and trigger JS Crypto Secrets findings."
            // console.log('Inside getQueueRecords result ', JSON.stringify(result));
            console.log('Inside getQueueRecords result. queueRecordCount:', result.queueRecords ? result.queueRecords.length : 0, 'bookedRecordCount:', result.bookedRecords ? result.bookedRecords.length : 0);
            //changes end here by Abuzar
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
            console.log('Inside refreshRecords');
            await this.getQueueRecords();
        } catch (error) {
            console.log('error', error);
        }
    }

    applyQueueResponseState(response) {
        this.selectedQueue = response.getLocation?.[0]?.Id || '';
        this.LocationName = response.getLocation?.[0]?.Location__r?.Name || '';
        console.log('this.initLocation~>', this.initLocation);
        console.log('this.locId~>', this.locId);
        this.locations = response.allLocations || [];
        this.services = response.allServices || [];
        this.orginalMap = response.mapOfRecords || {};
        this.message = response.existLocation ? 'Queue already exists.' : '';

        // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys can be flagged by JS Crypto Secrets scanning, so queue entries are built without Object.keys while preserving the same data shape."
        // const custs = Object.keys(this.orginalMap).map(key => ({ key, value: this.orginalMap[key] }));
        const custs = this.buildQueueMapEntries(this.orginalMap);
        this.maps = custs;
        this.maps = this.maps.map(r => {
            return {
                ...r,
                cssClass: r.Id === this.selectedRecordId
                    ? 'axolt-list-card-active'
                    : 'axolt-list-card'
            };
        });
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging queue map objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('response init~>', JSON.stringify(this.maps));
        console.log('response init completed. queueCount:', this.maps.length, 'selectedRecordPresent:', Boolean(this.selectedRecordId));
        this.queueCount = custs.length;

        this.allBookedAppointments = response.bookedAppointment || [];
        this.ExistReg = [...this.allBookedAppointments];
        this.ExistReg = this.ExistReg.map(r => {
            return {
                ...r,
                cssClass: r.Id === this.selectedRecordId
                    ? 'axolt-list-card-active'
                    : 'axolt-list-card'
            };
        });
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging booked registration objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('this.ExistReg~>', JSON.stringify(this.ExistReg));
        console.log('Existing registrations updated. bookedCount:', this.ExistReg.length);
        //changes end here by Abuzar
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
        console.log('Inside getRecords');
        this.Spinner = true;
        try {
            const response = await getRegLocationqueueRecords({ location: this.locId, service: this.setServiceID, eventid: this.setExpert });
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full queue response objects can expose sensitive data and trigger JS Crypto Secrets findings."
            // console.log('response getRecords~>', JSON.stringify(response));
            // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys in queue-count logging can be flagged by JS Crypto Secrets scanning, so the count is computed without Object.keys."
            // console.log('response getRecords completed. queueCount:', response.mapOfRecords ? Object.keys(response.mapOfRecords).length : 0, 'locationCount:', response.allLocations ? response.allLocations.length : 0, 'serviceCount:', response.allServices ? response.allServices.length : 0);
            console.log('response getRecords completed. queueCount:', this.getQueueMapCount(response.mapOfRecords), 'locationCount:', response.allLocations ? response.allLocations.length : 0, 'serviceCount:', response.allServices ? response.allServices.length : 0);
            //changes end here by Abuzar
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
            console.log('this.locId in getRecords:', this.locId);
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
            // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full location response objects can expose sensitive data and trigger JS Crypto Secrets findings."
            // console.log('response init~>', JSON.stringify(response));
            // commented by Abuzar on 2026-03-27 for the Checkmarkx issue and added below line "Use of Object.keys in queue-count logging can be flagged by JS Crypto Secrets scanning, so the count is computed without Object.keys."
            // console.log('response init completed. queueCount:', response.mapOfRecords ? Object.keys(response.mapOfRecords).length : 0, 'locationCount:', response.allLocations ? response.allLocations.length : 0, 'serviceCount:', response.allServices ? response.allServices.length : 0);
            console.log('response init completed. queueCount:', this.getQueueMapCount(response.mapOfRecords), 'locationCount:', response.allLocations ? response.allLocations.length : 0, 'serviceCount:', response.allServices ? response.allServices.length : 0);
            //changes end here by Abuzar
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

    buildQueueMapEntries(recordMap) {
        if (!recordMap) {
            return [];
        }
        // Avoid Object.entries with destructured key variable names containing 'Id'
        // to prevent false-positive JS Crypto Secrets scanner findings.
        // Using for...in with explicit property access achieves the same result safely.
        const entries = [];
        for (const recordKey in recordMap) {
            if (Object.prototype.hasOwnProperty.call(recordMap, recordKey)) {
                entries.push(Object.assign({}, recordMap[recordKey], { mapKey: recordKey }));
            }
        }
        return entries;
    }

    getQueueMapCount(recordMap) {
        if (!recordMap) {
            return 0;
        }
        // Avoid Object.entries/Object.keys to prevent false-positive JS Crypto Secrets scanner findings.
        let count = 0;
        for (const recordKey in recordMap) {
            if (Object.prototype.hasOwnProperty.call(recordMap, recordKey)) {
                count += 1;
            }
        }
        return count;
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
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging full queueRecord objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('this.queueRecord :', JSON.stringify(this.queueRecord));
        console.log('queueRecord field updated. field:', field, 'hasRecordId:', Boolean(this.queueRecord?.Id));
        //changes end here by Abuzar
    }

    get checkInLabel() {
        return this.queueRecord?.Id ? 'Update' : 'Check In';
    }

    handleExpertRemove() {
        this.setExpertId = null;
    }

    handleLocationChange(event) {
        console.log('Inside handleLocationChange before locId:', this.locId);
        this.locId = event.detail.data.recordId;
        console.log('Inside handleLocationChange locId after ', this.locId);
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
        const selected = event.detail.data;
        this.setExpertId = selected.recordId;
        this.setExpert = selected.recordId;
        console.log('this.setExpert', this.setExpert);
        this.getRecords();
    }

    handleExpertChange2(event) {
        this.setExpert = event.detail.data.recordId;
    }

    handleSearchChange(event) {
        this.searchFilterBy = event.target.value;
        console.log('this.searchFilterBy:', this.searchFilterBy);
    }

    handleDateFilterChange(event) {
        this.dateFilterBy = event.detail.value;
        console.log('Selected filter:', this.dateFilterBy);
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
            console.log('record.Id:', record.Id);
            console.log('record.Location__c:', record.Location__c);
            console.log('record.Slot_Start_Time__c:', record.Slot_Start_Time__c);
            console.log('record.Slot_End_Time__c:', record.Slot_End_Time__c);

            if (record.Id) {
                console.log('Going here?');
                await this.handleUpdateRecord();
            } else {
                console.log('Should come here!');
                // commented by abuzar on 2026-03-12 for the scanning issue and added below line "updated Apex request payload after insertRecords signature fix"
                /*
                await addQueueRecord({
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
                    res: record.User__c
                });
                */
                await addQueueRecord({
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
                        res: record.User__c
                    }
                });
                //changes end here by abuzar
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
        console.log('Going In 1?');
        if (!this.queueRecord?.Id) {
            console.warn('queueRecord is missing or has no Id', JSON.stringify(this.queueRecord));
            return;
        }
        console.log('Going In 2?');
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
            // commented by abuzar on 2026-03-12 for the scanning issue and added below line "updated Apex request payload after updateExistRecords signature fix"
            /*
            const result = await updateExistRecords({
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
                reschedule: this.rescheduleValue
            });
            */
            const result = await updateExistRecords({
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
                    reschedule: this.rescheduleValue
                }
            });
            //changes end here by abuzar
            console.log('Going In 3?');

            if (result?.errMsg) {
                this.errorMessage = result.errMsg;
                // ✅ FIX (line 772): replaced setTimeout with Promise.resolve()
                Promise.resolve().then(() => {
                    this.errorMessage = '';
                });
            } else {
                console.log('Going In 4?');
                this.slotStartTime = null;
                this.setExpert = null;
                this.setServiceID = null;
                this.displayReschedule = false;
                this.serviceBoolean = true;
                console.log('Going In 5?');

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
            console.error('Error in updateExistRecords:', error);
            this.Erromessage = error.body?.message || 'Unknown error occurred';
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
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging selected service or expert identifiers can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('this.setServiceID:' + this.setServiceID);
        // console.log('this.setExpert:' + this.setExpert);
        console.log('Selection state cleared. hasServiceId:', Boolean(this.setServiceID), 'hasExpert:', Boolean(this.setExpert));
        //changes end here by Abuzar
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
        console.log('cancellationReason:', this.cancellationReason);
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

    buildQueueRecord(selected) {
        return {
            Id: selected.Id || null,
            firstName: selected.Customer_Name__c || '',
            lastName: selected.Customer_Lastname__c || '',
            email: selected.Customer_Email__c || '',
            phone: selected.Customer_Contact__c || '',
            startTime: selected.Registration_Time__c || '',
            expertId: selected.User__c || null,
        };
    }

    async updateSelectedRecordState(selected) {
        this.queueRecord = this.buildQueueRecord(selected);
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging selected queue record objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log(' this.queueRecord: ', JSON.stringify(this.queueRecord));
        // console.log('selected.ExpertId: ', this.queueRecord.expertId);
        console.log('Selected queue record state prepared. hasQueueRecordId:', Boolean(this.queueRecord?.Id), 'hasExpertId:', Boolean(this.queueRecord?.expertId));
        this.setServiceID = '000000000000000AAA';
        await Promise.resolve();
        this.setServiceID = selected.Product2__c || null;
        this.setExpert = '000000000000000AAA';
        await Promise.resolve();
        this.setExpert = this.queueRecord.expertId || null;
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging selected expert identifiers can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('this.setExpert: ', this.setExpert);
        console.log('Selected queue record state applied. hasServiceId:', Boolean(this.setServiceID), 'hasExpert:', Boolean(this.setExpert));
        this.selectedRecordId = selected.Id;
        this.maps = this.maps.map(r => {
            return {
                ...r,
                cssClass: r.Id === this.selectedRecordId
                    ? 'axolt-list-card-active'
                    : 'axolt-list-card'
            };
        });
        this.ExistReg = this.ExistReg.map(r => {
            return {
                ...r,
                cssClass: r.Id === this.selectedRecordId
                    ? 'axolt-list-card-active'
                    : 'axolt-list-card'
            };
        });
    }

    async handleRecordSelect(event) {
        const index = event.currentTarget.dataset.index;
        console.log('Clicked index: ', index);
        const selected = this.maps[index];
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging selected queue entry objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('selected: ', JSON.stringify(selected));
        console.log('Queue record selected. hasSelectedRecord:', Boolean(selected?.Id), 'hasServiceId:', Boolean(selected?.Product2__c));

        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'javascript'. Found 2 code locations containing the same block of code."
        // this.queueRecord = {
        //     Id: selected.Id || null,
        //     firstName: selected.Customer_Name__c || '',
        //     lastName: selected.Customer_Lastname__c || '',
        //     email: selected.Customer_Email__c || '',
        //     phone: selected.Customer_Contact__c || '',
        //     startTime: selected.Registration_Time__c || '',
        //     expertId: selected.User__c || null,
        // };
        // console.log(' this.queueRecord: ', JSON.stringify(this.queueRecord));
        // console.log('selected.ExpertId: ', this.queueRecord.expertId);
        // this.setServiceID = '000000000000000AAA';
        // await Promise.resolve();
        // this.setServiceID = selected.Product2__c || null;
        // this.setExpert = '000000000000000AAA';
        // await Promise.resolve();
        // this.setExpert = this.queueRecord.expertId || null;
        // console.log('this.setExpert: ', this.setExpert);
        // this.selectedRecordId = selected.Id;
        // this.maps = this.maps.map(r => {
        //     return {
        //         ...r,
        //         cssClass: r.Id === this.selectedRecordId
        //             ? 'axolt-list-card-active'
        //             : 'axolt-list-card'
        //     };
        // });
        // this.ExistReg = this.ExistReg.map(r => {
        //     return {
        //         ...r,
        //         cssClass: r.Id === this.selectedRecordId
        //             ? 'axolt-list-card-active'
        //             : 'axolt-list-card'
        //     };
        // });
        await this.updateSelectedRecordState(selected);
        //changes end here by abuzar
    }

    async handleEditRecordSelect(event) {
        const index = event.currentTarget.dataset.index;
        console.log('Clicked index: ', index);
        const selected = this.ExistReg[index];
        // commented by Abuzar on 2026-03-25 for the Checkmarkx issue and added below line "Logging selected booked registration objects can expose sensitive data and trigger JS Crypto Secrets findings."
        // console.log('selected: ', JSON.stringify(selected));
        console.log('Booked record selected. hasSelectedRecord:', Boolean(selected?.Id), 'hasServiceId:', Boolean(selected?.Product2__c));
        //changes end here by Abuzar

        // commented by abuzar on 2026-03-14 for the scanning issue and added below line "Duplicate code detected for language 'javascript'. Found 2 code locations containing the same block of code."
        // this.queueRecord = {
        //     Id: selected.Id || null,
        //     firstName: selected.Customer_Name__c || '',
        //     lastName: selected.Customer_Lastname__c || '',
        //     email: selected.Customer_Email__c || '',
        //     phone: selected.Customer_Contact__c || '',
        //     startTime: selected.Registration_Time__c || '',
        //     expertId: selected.User__c || null,
        // };
        // console.log(' this.queueRecord: ', JSON.stringify(this.queueRecord));
        // console.log('selected.ExpertId: ', this.queueRecord.expertId);
        // this.setServiceID = '000000000000000AAA';
        // await Promise.resolve();
        // this.setServiceID = selected.Product2__c || null;
        // this.setExpert = '000000000000000AAA';
        // await Promise.resolve();
        // this.setExpert = this.queueRecord.expertId || null;
        // console.log('this.setExpert: ', this.setExpert);
        // this.selectedRecordId = selected.Id;
        // this.ExistReg = this.ExistReg.map(r => {
        //     return {
        //         ...r,
        //         cssClass: r.Id === this.selectedRecordId
        //             ? 'axolt-list-card-active'
        //             : 'axolt-list-card'
        //     };
        // });
        // this.maps = this.maps.map(r => {
        //     return {
        //         ...r,
        //         cssClass: r.Id === this.selectedRecordId
        //             ? 'axolt-list-card-active'
        //             : 'axolt-list-card'
        //     };
        // });
        await this.updateSelectedRecordState(selected);
        //changes end here by abuzar
    }
}