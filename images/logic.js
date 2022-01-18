let i = 1e3;
setInterval(function () {
  var t = document.getElementById("hour"),
    e = document.getElementById("minute"),
    n = Date.now() / 1e3,
    u = Math.trunc((n / 60 / 60) % 24),
    r = Math.trunc((n / 60) % 60),
    c = 30 * (Math.trunc(u % 10) - 1) + 30,
    a = 50 + 25 * Math.trunc(u / 11),
    h = 30 + 30 * (Math.trunc(r % 10) - 1),
    o = 125 + 25 * Math.trunc(r / 11);
  (u = u < 10 ? "0".concat(u.toString()) : u),
    (r = r < 10 ? "0".concat(r.toString()) : r),
    (i = 1e3 * (60 - (n % 60))),
    t.setAttribute("x", Math.trunc(c)),
    t.setAttribute("y", Math.trunc(a)),
    e.setAttribute("x", Math.trunc(h)),
    e.setAttribute("y", Math.trunc(o)),
    (document.getElementById("hour").innerHTML = u),
    (document.getElementById("minute").innerHTML = r);
}, 1e3);
