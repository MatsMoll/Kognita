$('.barchart-demo').each(function(index, element){          
    var ctx = element.getContext("2d");
    
    var t = ctx.createLinearGradient(0,500,0,150);
    t.addColorStop(0,"#fa5c7c"),t.addColorStop(1,"#727cf5");

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels:   ["", "", "", "", "", "", "", ""],
            datasets: [{
                data: [9, 8, 10, 7, 9, 9, 2, 4],
                backgroundColor: t,
                borderColor: t
            }]
        },
        options: {
            legend: {
                display: false
            },
            scales: {
                yAxes: [{
                    display: false,
                    ticks: {
                        min: 0,
                        max: 10,
                    }
                }],
                xAxes: [{
                    display: false
                }]
            }
        }
    });
});


$('.linechart-demo').each(function(index, element){          
    var ctx = element.getContext("2d");
    
    var t = ctx.createLinearGradient(0,500,0,150);
    t.addColorStop(0,"#fa5c7c"),t.addColorStop(1,"#727cf5");

    new Chart(ctx, {
        type: 'line',
        data: {
            labels:   ["", "", "", "", "", "", "", ""],
            datasets: [{
                data: [40, 60, 50, 60, 80, 70, 92, 94],
                backgroundColor: "rgba(10, 207, 151, 0.3)",
                borderColor: "#0acf97",
            },
            {
                data: [46, 49.9, 56.5, 62.5, 69, 74.75, 81.5, 88.25],
                backgroundColor: "transparent",
                borderColor: "#727cf5",
                borderDash: [5,5]
            }]
        },
        options: {
            legend: {
                display: false
            },
            scales: {
                yAxes: [{
                    gridLines: {
                        display: false
                    },
                    ticks: {
                        min: 0,
                        max: 100,
                    }
                }],
                xAxes: [{
                    type: 'category',
                    labels: ['4/12', '7/12', '8/12', '10/12', '14/12', '20/12', '21/12'],
                    gridLines: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                }]
            }
        }
    });
});