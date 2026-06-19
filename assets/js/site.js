/* Divvylore Journal — small progressive-enhancement helpers */
(function () {
  "use strict";

  // --- Mobile section menu toggle -----------------------------------------
  var toggle = document.querySelector(".nav-toggle");
  var nav = document.getElementById("site-nav");

  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var open = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  // --- Reading progress could be added here later -------------------------
})();
