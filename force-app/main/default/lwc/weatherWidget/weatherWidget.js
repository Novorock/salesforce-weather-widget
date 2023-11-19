import { LightningElement, track, wire } from 'lwc';
import getCurrentWeather from '@salesforce/apex/WeatherWidgetService.getCurrentWeather';
import getCurrentForecast from '@salesforce/apex/WeatherWidgetService.getCurrentForecast';

export default class WeatherWidget extends LightningElement {
    @track
    location;
    @track
    currentWeather = {
        Time: '',
        Temperature: 0,
        Wind: 1,
        Description: '',
        IconUrl: "https://openweathermap.org/img/wn/04n@4x.png"
    };
    forecast = [];

    @track
    weatherHourData = [];
    hasRendered = false;
    hourIds = [0, 1, 2, 3, 4];
    previousDisabled = true;
    nextDisabled = false;

    connectedCallback() {
        this.template.addEventListener("refresh", (event => {
            this.location = event.detail;
            this.refresh();
        }));
    }

    refresh() {
        getCurrentWeather({ location: this.location }).then((data) => {
            let weather = JSON.parse(JSON.stringify(data));
            this.currentWeather.Time = new Date(weather.timestamp * 1000).toLocaleDateString("en-US", {
                weekday: 'short',
                month: 'short',
                day: 'numeric',
                year: 'numeric'
            });
            this.currentWeather.Temperature = weather.temperature;
            this.currentWeather.Wind = weather.wind;
            this.currentWeather.Description = weather.description;
            this.currentWeather.IconUrl = weather.iconUrl;
        }).catch((error) => {
            console.log(error);
        });

        getCurrentForecast({ location: this.location }).then((data) => {
            let forecast = JSON.parse(JSON.stringify(data)).forecast;
            this.forecast = [];
            for (let hour of forecast) {
                this.forecast.push({
                    Time: new Date(hour.timestamp * 1000).getHours() + ':00',
                    Temperature: hour.temperature,
                    Wind: hour.wind,
                    Description: hour.description,
                    IconUrl: hour.iconUrl
                });
            }

            this.refineHour();
        });
    }

    renderedCallback() {
        if (!this.hasRendered) {
            let container = this.template.querySelector(".forecast-container");
            this.resize(container);

            window.addEventListener("resize", (event) => {
                this.resize(container);
                this.refineHour();
            });

            this.hasRendered = true;
        }

        let icons = this.template.querySelectorAll(".icon128, .icon64");
        for (let icon of icons) {
            this.renderIcon(icon);
        }
    }

    resize(container) {
        let width = container?.clientWidth;
        if (width >= 450) {
            this.hourIds = [0, 1, 2, 3, 4];
        } else if (width >= 150) {
            this.hourIds = [0, 1, 2];
        } else {
            this.hourIds = [0];
        }
        this.previousDisabled = true;
        this.nextDisabled = false;
    }

    renderIcon(icon) {
        icon.style.backgroundImage = "url('" + icon.dataset.url + "')";
        icon.style.backgroundRepeat = "no-repeat";
        icon.style.backgroundSize = "100% 100%";
    }

    nextHour(event) {
        event.target?.blur();

        for (let i = 0; i < this.hourIds.length; i++) {
            this.hourIds[i] += 1;
        }

        let last = this.hourIds.length - 1;

        if (this.hourIds[last] === this.forecast.length - 1) {
            this.nextDisabled = true;
        } else {
            this.nextDisabled = false;
        }

        this.previousDisabled = false;
        this.refineHour();
    }

    previousHour(event) {
        event.target?.blur();

        for (let i = 0; i < this.hourIds.length; i++) {
            this.hourIds[i] -= 1;
        }

        if (this.hourIds[0] === 0) {
            this.previousDisabled = true;
        } else {
            this.previousDisabled = false;
        }

        this.nextDisabled = false;
        this.refineHour();
    }

    refineHour() {
        this.weatherHourData = [];

        for (let id of this.hourIds) {
            this.weatherHourData.push(this.forecast[id]);
        }
    }
}