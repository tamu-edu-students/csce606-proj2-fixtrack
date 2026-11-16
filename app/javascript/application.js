// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

function syncRepairRecordsToggle(section) {
  const details = Array.from(section.querySelectorAll("tbody .ticket-repair-history__notes"));
  const button = section.querySelector("[data-repair-records-toggle]");
  const allExpanded = details.length > 0 && details.every((item) => item.open);

  button.setAttribute("aria-expanded", String(allExpanded));
  button.textContent = allExpanded ? "Collapse all" : "Expand all";
}

document.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;

  const button = event.target.closest("[data-repair-records-toggle]");
  if (!button) return;

  const section = button.closest(".ticket-repair-history");
  if (!section) return;

  const details = Array.from(section.querySelectorAll("tbody .ticket-repair-history__notes"));
  const expandAll = details.some((item) => !item.open);
  details.forEach((item) => {
    item.open = expandAll;
  });
  syncRepairRecordsToggle(section);
});

document.addEventListener(
  "toggle",
  (event) => {
    if (
      !(event.target instanceof HTMLDetailsElement) ||
      !event.target.matches(".ticket-repair-history__notes")
    ) return;

    const section = event.target.closest(".ticket-repair-history");
    if (section) syncRepairRecordsToggle(section);
  },
  true
);

function showRepairPanel(container, targetPanel) {
  container.querySelectorAll("[data-repair-panel]").forEach((panel) => {
    if (
      panel !== targetPanel &&
      panel.dataset.repairPanel === "edit" &&
      !panel.hidden
    ) {
      panel.querySelector("form").reset();
    }

    panel.hidden = panel !== targetPanel;
  });

  container.querySelectorAll("[data-repair-record-edit]").forEach((link) => {
    link.setAttribute(
      "aria-expanded",
      String(link.getAttribute("aria-controls") === targetPanel.id)
    );
  });

  const history = container.closest(".ticket-show-layout")?.querySelector(
    ".ticket-repair-history"
  );
  history?.querySelectorAll("[data-repair-record-row]").forEach((row) => {
    const isEditing =
      row.dataset.repairRecordRow === targetPanel.dataset.repairRecordId;
    const indicator = row.querySelector("[data-repair-editing-indicator]");

    if (isEditing) {
      row.setAttribute("aria-current", "true");
    } else {
      row.removeAttribute("aria-current");
    }

    indicator.hidden = !isEditing;
  });
}

document.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;

  const deleteStartLink = event.target.closest("[data-repair-delete-start]");
  if (deleteStartLink) {
    const actions = deleteStartLink.closest(".ticket-repair-history__actions");
    const actionLinks = actions?.querySelector("[data-repair-actions]");
    const confirmation = actions?.querySelector("[data-repair-delete-confirmation]");
    if (!actions || !actionLinks || !confirmation) return;

    event.preventDefault();
    actionLinks.hidden = true;
    confirmation.hidden = false;
    deleteStartLink.setAttribute("aria-expanded", "true");
    confirmation.querySelector("[data-repair-record-delete]").focus();
    return;
  }

  const deleteCancelLink = event.target.closest("[data-repair-delete-cancel]");
  if (deleteCancelLink) {
    const actions = deleteCancelLink.closest(".ticket-repair-history__actions");
    const actionLinks = actions?.querySelector("[data-repair-actions]");
    const confirmation = actions?.querySelector("[data-repair-delete-confirmation]");
    const deleteStart = actionLinks?.querySelector("[data-repair-delete-start]");
    if (!actions || !actionLinks || !confirmation || !deleteStart) return;

    event.preventDefault();
    confirmation.hidden = true;
    actionLinks.hidden = false;
    deleteStart.setAttribute("aria-expanded", "false");
    deleteStart.focus();
    return;
  }

  const deleteLink = event.target.closest("[data-repair-record-delete]");
  if (deleteLink) {
    const form = deleteLink.closest("form");
    if (!form) return;

    event.preventDefault();
    form.requestSubmit();
    return;
  }

  const editLink = event.target.closest("[data-repair-record-edit]");
  if (editLink) {
    const panel = document.getElementById(editLink.getAttribute("aria-controls"));
    const container = editLink.closest(".ticket-show-layout")?.querySelector(
      ".ticket-repair-panel"
    );
    if (!panel || !container) return;

    event.preventDefault();
    if (panel.hidden) {
      showRepairPanel(container, panel);
      panel.scrollIntoView({ block: "nearest" });
    }
    return;
  }

  const cancelButton = event.target.closest("[data-repair-panel-cancel]");
  if (!cancelButton) return;

  const container = cancelButton.closest(".ticket-repair-panel");
  const editPanel = cancelButton.closest('[data-repair-panel="edit"]');
  const addPanel = container?.querySelector('[data-repair-panel="add"]');
  if (!container || !editPanel || !addPanel) return;

  editPanel.querySelector("form").reset();
  showRepairPanel(container, addPanel);
});

function repairDraftKey(form) {
  return `fixtrack:repair-record-draft:${form.dataset.repairTicketId}`;
}

function repairDraftFields(form) {
  return {
    title: form.querySelector('[name="repair_record[title]"]'),
    description: form.querySelector('[name="repair_record[description]"]')
  };
}

function restoreRepairDrafts() {
  document.querySelectorAll("form[data-repair-add-form]").forEach((form) => {
    const key = repairDraftKey(form);
    const fields = repairDraftFields(form);
    const title = sessionStorage.getItem(`${key}:title`);
    const description = sessionStorage.getItem(`${key}:description`);

    if (title !== null) fields.title.value = title;
    if (description !== null) fields.description.value = description;
  });
}

function scheduleAutoDismissal() {
  document.querySelectorAll("[data-auto-dismiss]").forEach((message) => {
    window.setTimeout(() => {
      message.hidden = true;
    }, Number(message.dataset.autoDismiss));
  });
}

function initializeRepairRecordPage() {
  restoreRepairDrafts();
  scheduleAutoDismissal();
}

document.addEventListener("input", (event) => {
  if (!(event.target instanceof Element)) return;

  const form = event.target.closest("form[data-repair-add-form]");
  if (!form) return;

  const key = repairDraftKey(form);
  const fields = repairDraftFields(form);
  sessionStorage.setItem(`${key}:title`, fields.title.value);
  sessionStorage.setItem(`${key}:description`, fields.description.value);
});

document.addEventListener("submit", (event) => {
  const form = event.target;
  if (!(form instanceof HTMLFormElement)) return;

  if (form.dataset.confirm && !window.confirm(form.dataset.confirm)) {
    event.preventDefault();
    return;
  }

  if (form.matches("[data-repair-add-form]")) {
    const key = repairDraftKey(form);
    sessionStorage.removeItem(`${key}:title`);
    sessionStorage.removeItem(`${key}:description`);
  }
});

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeRepairRecordPage, { once: true });
} else {
  initializeRepairRecordPage();
}
