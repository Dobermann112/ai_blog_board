import { Controller } from "@hotwired/stimulus"

// タグ選択チェックボックスを検索語で絞り込む（サーバー通信なし）
export default class extends Controller {
  static targets = ["query", "list"]

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()

    this.listTarget.querySelectorAll("[data-tag-name]").forEach((label) => {
      const matches = label.dataset.tagName.includes(query)
      label.classList.toggle("hidden", query.length > 0 && !matches)
    })
  }
}
