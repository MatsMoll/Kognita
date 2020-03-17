function fetchHistogram() {
    let url = "/api/subject-tests/" + parseSubjectID() + "/results/score-histogram"

    fetch(url, {
        method: "GET",
        headers: {
            "Accept": "application/json, text/plain, */*",
        }
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        updateHistogramWith(json);
    })
    .then(function (html) {
        $("#user-status").html(html);
    });
}

function parseSubjectID() {
    let path = window.location.pathname;
    let splitURI = "subject-tests/";
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/results")
    ));
}

function updateHistogramWith(json) {
    let scores = json["scores"];
    let labels = scores.map(x => x["score"]);
    let data = scores.map(x => x["amount"]);
    var ctx = document.getElementById("score-histogram").getContext('2d');

    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Resultat fordeling',
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
                    }
                }]
            }
        }
    });
}

fetchHistogram();