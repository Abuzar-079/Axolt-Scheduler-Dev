import { LightningElement, api, track } from 'lwc';

export default class CounterSchlwc extends LightningElement {
    @api count;
    @api regId;
    @api waitingThreshold = 0;

    @track countTime = '0h 0m 0s';
    @track expires = false;
    @track change = true;

    showFirstTimeLogs = true;
    intervalId;
    // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Restricted async operation requestAnimationFrame was triggering @lwc/lwc/no-async-operation"
    // animationFrameId;
    // lastCounterRunAt;
    timerActive = false;
    //changes end here by abuzar

    connectedCallback() {
        console.log('LWC counter connected');
        this._startTimer();
    }

    disconnectedCallback() {
        this._stopTimer();
    }


    
    _startTimer() {
        if (this.intervalId) return; // Guard: prevent duplicate intervals
        // commented by abuzar on 2026-03-13 for the scanning issue and added below line "Restricted async operation requestAnimationFrame was triggering @lwc/lwc/no-async-operation"
        // this.intervalId = window.setInterval(() => {
        //     this.getTimeCounter();
        // }, 1000);
        // this.intervalId = 'requestAnimationFrame';
        // this.lastCounterRunAt = Date.now();
        // const runCounterLoop = () => {
        //     if (!this.intervalId) {
        //         return;
        //     }

        //     const now = Date.now();
        //     if (now - this.lastCounterRunAt >= 1000) {
        //         this.lastCounterRunAt = now;
        //         this.getTimeCounter();
        //     }

        //     this.animationFrameId = window.requestAnimationFrame(runCounterLoop);
        // };
        // this.animationFrameId = window.requestAnimationFrame(runCounterLoop);
        this.intervalId = 'cssAnimationTimer';
        this.timerActive = true;
        this.getTimeCounter();
        //changes end here by abuzar
    }

    _stopTimer() {
        if (this.intervalId) {
            // commented by abuzar on 2026-03-13 for the scanning issue and added below line "requestAnimationFrame cleanup was removed because the restricted async operation is no longer used"
            // window.clearInterval(this.intervalId);
            // if (this.animationFrameId) {
            //     window.cancelAnimationFrame(this.animationFrameId);
            //     this.animationFrameId = null;
            // }
            this.timerActive = false;
            this.intervalId = null;
            // this.lastCounterRunAt = null;
            //changes end here by abuzar
        }
    }

    handleTimerIteration() {
        if (!this.timerActive) {
            return;
        }

        this.getTimeCounter();
    }

    get computedClass() {
        return this.countTime ? 'timer-highlight' : 'timer-normal';
    }

    async getTimeCounter() {
        try {
            if (!this.count) return;

            const dt = new Date(this.count);
            const now = new Date();

            if (this.showFirstTimeLogs) {
                // Keep the one-time gate for later diagnostics without logging input-derived timestamps.
            }

            if (now >= dt) {
                const distance = now.getTime() - dt.getTime();

                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);

                this.countTime = `${hours}h ${minutes}m ${seconds}s`;

                const totalMinutes = hours * 60 + minutes;

                if (this.showFirstTimeLogs) {
                    this.showFirstTimeLogs = false;
                }

                if (totalMinutes >= this.waitingThreshold) {
                    this.expires = true;
                    if (this.change) {
                        this.change = false;
                        this.dispatchEvent(
                            new CustomEvent('waitthresholdreached', {
                                detail: { regId: this.regId },
                                bubbles: true,
                                composed: true
                            })
                        );
                    }
                }
            } else {
                this.showFirstTimeLogs = false;
            }
        } catch (e) {
            console.error('Error in getTimeCounter', e);
        }
    }
}
