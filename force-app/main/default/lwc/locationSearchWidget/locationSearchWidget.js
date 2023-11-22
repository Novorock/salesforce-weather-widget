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
    needRefresh = false;

    connectedCallback() {
        getDefaultLocation({}).then((data) => {
            this.default = `${data.City},${data.Country}`;
            this.location = this.default;
            this.q = `${data.City},${data.Country}`;
            this.refresh();
        });
    }

    async requestGeoData(q) {
        await getGeoData({ location: q }).then((geoData) => {
            if (geoData != null || geoData != undefined || geoData?.length > 0) {
                let data = JSON.parse(JSON.stringify(geoData));
                this.location = `${data[0].name},${data[0].country}`;
            } else {
                this.q = this.location = this.default;
            }
        }).catch((error) => {
            this.q = this.location = this.default;
        });
    }

    async refresh() {
        await this.requestGeoData(this.q);
        this.callRefresh(this.q);

        let inputField = this.template.querySelector(".location");
        inputField.innerText = this.location;

        inputField.addEventListener("keypress", (event) => {
            if (event.key === "Enter" || event.key === 13) {
                event.preventDefault();
                this.refineLocation(event.target.innerText);
            }
        });
    }

    renderedCallback() {
    }

    refineLocation(loc) {
        if (loc === "") {
            this.q = this.default;
        } else if (loc !== this.default) {
            this.callLoading();
            this.q = loc;
            this.refresh();
        }
    }

    callRefresh(loc) {
        this.dispatchEvent(new CustomEvent('refresh', {
            bubbles: true,
            detail: loc
        }));
    }

    callLoading() {
        this.dispatchEvent(new CustomEvent('loading', {
            bubbles: true
        }));
    }

    editLocation(event) {
        let field = event.target;
        field.contentEditable = field.contentEditable === true ? false : true;
    }
}
