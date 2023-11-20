import { LightningElement, track } from 'lwc';
import getCurrentWeather from '@salesforce/apex/WeatherWidgetService.getCurrentWeather';
import getCurrentForecast from '@salesforce/apex/WeatherWidgetService.getCurrentForecast';

export default class WeatherWidget extends LightningElement {
    location;
    forecast = [];
    @track
    currentWeather = {
        Time: '',
        Temperature: 0,
        Wind: 1,
        Description: '',
        IconUrl: "https://openweathermap.org/img/wn/04n@4x.png"
    };
    @track
    weatherHourData = [];
    loading = true;
    hasRendered = false;
    sizeInitialized = false;
    from = 0;
    to = 2;
    previousDisabled = true;
    nextDisabled = false;

    connectedCallback() {
        this.template.addEventListener("loading", (event) => {
            this.loading = true;
        });

        this.template.addEventListener("refresh", (event) => {
            this.location = event.detail;
            this.refresh(this.location);
        });

        window.addEventListener("resize", (event) => {
            this.initSize();
            this.renderHourData();
        });
    }

    async requestWeatherData(q) {
        await getCurrentWeather({ location: q }).then((data) => {
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

        await getCurrentForecast({ location: q }).then((data) => {
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
        });
    }

    async refresh(q) {
        await this.requestWeatherData(q);
        this.hasRendered = false;
        this.loading = false;
        this.renderHourData();
    }

    initSize() {
        let container = this.template.querySelector('.forecast-container');
        let width = container?.clientWidth;

        if (width >= 450) {
            this.from = 0;
            this.to = 4;
        } else if (width >= 150) {
            this.from = 0;
            this.to = 2;
        } else {
            this.from = 0;
            this.to = 0;
        }
        this.previousDisabled = true;
        this.nextDisabled = false;
    }

    renderedCallback() {
        if (!this.sizeInitialized) {
            this.initSize();
            this.sizeInitialized = true;
        }

        if (!this.hasRendered) {
            let icon = this.template.querySelector(".icon128");
            if (icon != null) {
                this.renderIcon(icon);
            }
            this.hasRendered = true;
        }

        if (!this.loading) {
            this.renderIcons(this.template.querySelectorAll(".icon64"));
        }
    }

    renderHourData() {
        this.weatherHourData = [];
        for (let i = this.from; i <= this.to; i++) {
            this.weatherHourData.push(this.forecast[i]);
        }
    }

    renderIcons(icons) {
        for (let icon of icons) {
            this.renderIcon(icon);
        }
    }

    renderIcon(icon) {
        icon.style.backgroundImage = "url('" + icon.dataset.url + "')";
        icon.style.backgroundRepeat = "no-repeat";
        icon.style.backgroundSize = "100% 100%";
    }

    nextHour(event) {
        event.target?.blur();

        this.from += 1;
        this.to += 1;

        if (this.to === this.forecast.length - 1) {
            this.nextDisabled = true;
        } else {
            this.nextDisabled = false;
        }

        this.previousDisabled = false;
        this.renderHourData();
    }

    previousHour(event) {
        event.target?.blur();

        this.from -= 1;
        this.to -= 1;

        if (this.from === 0) {
            this.previousDisabled = true;
        } else {
            this.previousDisabled = false;
        }

        this.nextDisabled = false;
        this.renderHourData();
    }
}