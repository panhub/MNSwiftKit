const topbar = document.querySelector(".topbar");
const revealTargets = document.querySelectorAll(".section-head, .install-card, .feature-card, .module-card, .api-doc, .notice");
const tocLinks = [...document.querySelectorAll(".toc a")];
const apiSections = tocLinks
  .map((link) => document.querySelector(link.getAttribute("href")))
  .filter(Boolean);
let ticking = false;

revealTargets.forEach((target, index) => {
  target.dataset.reveal = "";
  target.style.setProperty("--delay", `${Math.min(index % 8, 7) * 42}ms`);
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("is-visible");
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.14, rootMargin: "0px 0px -8% 0px" });

revealTargets.forEach((target) => revealObserver.observe(target));

const getScrollMarker = () => {
  const topbarHeight = topbar?.getBoundingClientRect().height || 0;
  return window.scrollY + topbarHeight + Math.min(window.innerHeight * 0.24, 180);
};

const getActiveSection = (sections, marker) => {
  return sections.reduce((current, section) => {
    const sectionTop = section.getBoundingClientRect().top + window.scrollY;
    return sectionTop <= marker ? section : current;
  }, null);
};

const setActiveLink = (links, activeId) => {
  links.forEach((link) => {
    const isActive = link.getAttribute("href") === `#${activeId}`;
    link.classList.toggle("is-active", isActive);
  });
};

const syncNavigation = () => {
  ticking = false;
  topbar.classList.toggle("is-scrolled", window.scrollY > 12);

  const marker = getScrollMarker();
  const activeApiSection = getActiveSection(apiSections, marker);

  const apiBounds = document.querySelector("#api")?.getBoundingClientRect();
  const isInApiArea = apiBounds && apiBounds.top <= window.innerHeight * 0.65 && apiBounds.bottom > (topbar?.getBoundingClientRect().height || 0);
  setActiveLink(tocLinks, isInApiArea && activeApiSection ? activeApiSection.id : "");
};

const requestNavigationSync = () => {
  if (ticking) return;
  ticking = true;
  window.requestAnimationFrame(syncNavigation);
};

document.querySelectorAll(".module-card").forEach((card) => {
  card.addEventListener("mousemove", (event) => {
    const rect = card.getBoundingClientRect();
    const x = (event.clientX - rect.left) / rect.width - 0.5;
    const y = (event.clientY - rect.top) / rect.height - 0.5;
    card.style.setProperty("--ry", `${x * 5}deg`);
    card.style.setProperty("--rx", `${y * -5}deg`);
  });

  card.addEventListener("mouseleave", () => {
    card.style.setProperty("--ry", "0deg");
    card.style.setProperty("--rx", "0deg");
  });
});

window.addEventListener("scroll", requestNavigationSync, { passive: true });
window.addEventListener("resize", requestNavigationSync);
window.addEventListener("load", syncNavigation);
syncNavigation();
