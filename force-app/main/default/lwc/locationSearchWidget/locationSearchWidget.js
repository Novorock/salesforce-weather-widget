import { LightningElement, api, track } from 'lwc';
import getGeoData from '@salesforce/apex/WeatherGeoService.getGeoData';
import getDefaultLocation from '@salesforce/apex/WeatherGeoService.getDefaultLocation';

export default class LocationSearchWidget extends LightningElement {
    default;
    // Full name of the location
    @track
    location;
    // The name of the location to query
    @track
    q;
    @track
    loading = false;
    hasRendered = false;
    @track
    needRefresh = false;


    connectedCallback() {
        getDefaultLocation({}).then((data) => {
            this.default = `${data.Location__c},${data.Country__c}`;
            this.q = `${data.Location__c},${data.Country__c}`;
            this.init(this.q);
            this.callRefresh(this.q);
        });
    }

    init(loc) {
        let el = this.template.querySelector(".location");
        el.innerText = loc;
        el.addEventListener("keypress", (event) => {
            if (event.key === "Enter" || event.key === 13) {
                event.preventDefault();
                this.refineLocation(event.target.innerText);
            }
        });
    }

    renderedCallback() {
        if (this.needRefresh) {
            this.init(this.location);
            this.callRefresh(this.q);
            this.needRefresh = false;
        }
    }

    refineLocation(loc) {
        this.toggleLoading();

        if (loc === "") {
            this.q = this.default;
        } else if (loc !== this.default) {
            this.q = loc;
            getGeoData({ location: loc }).then((geoData) => {
                if (geoData != null || geoData != undefined || geoData?.length > 0) {
                    let data = JSON.parse(JSON.stringify(geoData));
                    this.location = `${data[0].name},${data[0].country}`;
                } else {
                    this.q = this.default;
                }
            }).catch((error) => {
                this.q = this.default;
            }).finally(() => {
                this.needRefresh = true;
                this.toggleLoading();
            });
        }
    }

    callRefresh(loc) {
        this.dispatchEvent(new CustomEvent('refresh', {
            bubbles: true,
            detail: loc
        }));
    }

    toggleLoading() {
        this.loading = this.loading === true ? false : true;
    }

    editLocation(event) {
        let field = event.target;
        field.contentEditable = field.contentEditable === true ? false : true;
    }
}
