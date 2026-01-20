import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "canvas", "preview", "fileInput", "captureBtn", "retakeBtn", "submitBtn", "loading"]

  connect() {
    this.stream = null
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1920 }, height: { ideal: 1080 } }
      })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.classList.remove("hidden")
      this.captureBtnTarget.classList.remove("hidden")
      this.previewTarget.classList.add("hidden")
      this.retakeBtnTarget.classList.add("hidden")
      this.submitBtnTarget.classList.add("hidden")
    } catch (err) {
      console.error("Camera error:", err)
      alert("Could not access camera. Please use file upload instead.")
    }
  }

  stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
    this.videoTarget.classList.add("hidden")
    this.captureBtnTarget.classList.add("hidden")
  }

  capture() {
    const video = this.videoTarget
    const canvas = this.canvasTarget
    
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    
    const ctx = canvas.getContext("2d")
    ctx.drawImage(video, 0, 0)
    
    this.previewTarget.src = canvas.toDataURL("image/jpeg", 0.9)
    this.previewTarget.classList.remove("hidden")
    this.retakeBtnTarget.classList.remove("hidden")
    this.submitBtnTarget.classList.remove("hidden")
    
    this.stopCamera()
  }

  retake() {
    this.previewTarget.classList.add("hidden")
    this.retakeBtnTarget.classList.add("hidden")
    this.submitBtnTarget.classList.add("hidden")
    this.startCamera()
  }

  fileSelected(event) {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
        this.submitBtnTarget.classList.remove("hidden")
        this.retakeBtnTarget.classList.remove("hidden")
        this.stopCamera()
      }
      reader.readAsDataURL(file)
    }
  }

  async submit() {
    this.loadingTarget.classList.remove("hidden")
    this.submitBtnTarget.disabled = true
    
    try {
      let imageData
      
      if (this.fileInputTarget.files.length > 0) {
        imageData = await this.fileToBase64(this.fileInputTarget.files[0])
      } else {
        imageData = this.canvasTarget.toDataURL("image/jpeg", 0.9)
      }
      
      const response = await fetch("/recipes/scan", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ image: imageData })
      })
      
      const data = await response.json()
      
      if (data.error) {
        alert(data.error)
      } else if (data.redirect_url) {
        window.location.href = data.redirect_url
      }
    } catch (err) {
      console.error("Upload error:", err)
      alert("Failed to process image. Please try again.")
    } finally {
      this.loadingTarget.classList.add("hidden")
      this.submitBtnTarget.disabled = false
    }
  }

  fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => resolve(reader.result)
      reader.onerror = reject
      reader.readAsDataURL(file)
    })
  }
}
