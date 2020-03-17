var xhr = new XMLHttpRequest();
var url = "/api/practice-sessions/histogram?numberOfWeeks=7";
xhr.open("GET", url, true);
xhr.setRequestHeader("Content-Type", "application/json");
xhr.onreadystatechange = function () {
    if (this.readyState != 4) return;

    if (this.status == 200) {
        var response = JSON.parse(this.responseText);
        let data = response.map(x => x["numberOfTasksCompleted"]);
        let labels = response.map(x => x["week"]);
        var ctx = document.getElementById("practice-time-histogram").getContext('2d');
        ctx.height = 200;
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Antall oppgaver fullført',
                    data: data,
                    backgroundColor:
                        'rgba(10,207,151,0.4)',
                    borderColor:
                        'rgba(10,207,151,1)',
                    borderWidth: 2
                }]
            },
            options: {
                aspectRatio: 4,
                maintainAspectRatio: true,
                legend: {
                    display: !1
                },
                tooltips: {
                    intersect: !1
                },
                hover: {
                    intersect: !0
                },
                plugins: {
                    filler: {
                        propagate: !1
                    }
                },
                scales: {
                    xAxes: [{
                        reverse: !0,
                        gridLines: {
                            color: "rgba(0,0,0,0.05)"
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Uke'
                        }
                    }],
                    yAxes: [{
                        ticks: {
                            stepSize: 10,
                            display: !1
                        },
                        min: 10,
                        max: 100,
                        display: !0,
                        borderDash: [5, 5],
                        gridLines: {
                            color: "rgba(0,0,0,0)",
                            fontColor: "#fff"
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Oppgaver'
                        }
                    }]
                }
            }
        });
    }
};
xhr.send();