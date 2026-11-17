import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "canvas", "preview", "fileInput", "captureBtn", "retakeBtn", "submitBtn", "loading", "multiPhotoContainer", "photoPreview", "addPhotoBtn", "clearPhotosBtn", "photoCount", "singlePhotoContainer"]

  connect() {
    this.stream = null
    this.capturedPhotos = []
    
    // Debug: Show info on page
    this.showDebug("Camera controller connected")
    this.showDebug("Available targets: " + this.constructor.targets.join(", "))
    this.showDebug("addPhotoBtn target found: " + !!this.addPhotoBtnTarget)
    
    // Test direct DOM query
    const addBtn = document.querySelector('[data-camera-target="addPhotoBtn"]')
    this.showDebug("Direct DOM query for addPhotoBtn: " + !!addBtn)
    
    // List all camera targets in DOM
    const allTargets = document.querySelectorAll('[data-camera-target]')
    const targetNames = Array.from(allTargets).map(t => t.dataset.cameraTarget)
    this.showDebug("All camera targets found: " + targetNames.join(", "))
  }

  showDebug(message) {
    const debugContent = document.getElementById('debug-content')
    const debugPanel = document.getElementById('debug-panel')
    
    if (debugContent) {
      const timestamp = new Date().toLocaleTimeString()
      debugContent.innerHTML += `[${timestamp}] ${message}\n`
      debugContent.scrollTop = debugContent.scrollHeight
    }
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    this.showDebug("Starting camera...")
    try {
      this.showDebug("Requesting camera access...")
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment", width: { ideal: 1920 }, height: { ideal: 1080 } }
      })
      this.showDebug("✓ Camera access granted")
      
      this.videoTarget.srcObject = this.stream
      this.videoTarget.classList.remove("hidden")
      this.captureBtnTarget.classList.remove("hidden")
      this.previewTarget.classList.add("hidden")
      this.retakeBtnTarget.classList.add("hidden")
      this.submitBtnTarget.classList.add("hidden")
      
      this.showDebug("✓ Camera started, capture button should be visible")
    } catch (err) {
      this.showDebug("✗ Camera error: " + err.message)
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
    this.showDebug("📸 CAPTURE METHOD CALLED!")
    
    const video = this.videoTarget
    const canvas = this.canvasTarget
    
    if (!video || !canvas) {
      this.showDebug("✗ Video or canvas target not found")
      return
    }
    
    this.showDebug("Setting canvas dimensions...")
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    
    this.showDebug("Drawing video to canvas...")
    const ctx = canvas.getContext("2d")
    ctx.drawImage(video, 0, 0)
    
    this.showDebug("Creating image from canvas...")
    this.previewTarget.src = canvas.toDataURL("image/jpeg", 0.9)
    this.previewTarget.classList.remove("hidden")
    this.retakeBtnTarget.classList.remove("hidden")
    this.submitBtnTarget.classList.remove("hidden")
    this.singlePhotoContainerTarget.classList.remove("hidden")
    
    // Always try to show addPhotoBtn using multiple methods
    this.showDebug("Attempting to show addPhotoBtn...")
    
    // Method 1: Stimulus target
    if (this.addPhotoBtnTarget) {
      this.addPhotoBtnTarget.classList.remove("hidden")
      this.showDebug("✓ addPhotoBtn shown via Stimulus target")
    } else {
      this.showDebug("✗ Stimulus target not found")
    }
    
    // Method 2: Direct DOM query
    const addBtn = document.querySelector('[data-camera-target="addPhotoBtn"]')
    if (addBtn) {
      addBtn.classList.remove("hidden")
      this.showDebug("✓ addPhotoBtn shown via DOM query")
    } else {
      this.showDebug("✗ DOM query not found")
    }
    
    // Method 3: Try by class (backup)
    const allButtons = document.querySelectorAll('button')
    const addPhotoButton = Array.from(allButtons).find(btn => 
      btn.textContent.includes('Add Another Photo')
    )
    if (addPhotoButton) {
      addPhotoButton.classList.remove("hidden")
      this.showDebug("✓ addPhotoBtn shown via text search")
    } else {
      this.showDebug("✗ Text search not found")
    }
    
    this.showDebug("Stopping camera...")
    this.stopCamera()
    this.showDebug("✓ Capture complete!")
  }

  retake() {
    this.previewTarget.classList.add("hidden")
    this.retakeBtnTarget.classList.add("hidden")
    this.addPhotoBtnTarget.classList.add("hidden")
    this.submitBtnTarget.classList.add("hidden")
    this.singlePhotoContainerTarget.classList.add("hidden")
    this.startCamera()
  }

  fileSelected(event) {
    this.showDebug("📁 FILE SELECTED!")
    
    const file = event.target.files[0]
    if (file) {
      this.showDebug("File found: " + file.name + " (" + file.size + " bytes)")
      
      const reader = new FileReader()
      reader.onload = (e) => {
        this.showDebug("File loaded, creating preview...")
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
        this.retakeBtnTarget.classList.remove("hidden")
        this.submitBtnTarget.classList.remove("hidden")
        this.singlePhotoContainerTarget.classList.remove("hidden")
        
        // Try to show addPhotoBtn - use fallback if target not found
        if (this.addPhotoBtnTarget) {
          this.addPhotoBtnTarget.classList.remove("hidden")
          this.showDebug("✓ addPhotoBtn shown via Stimulus target")
        } else {
          // Fallback: find by attribute directly
          const addBtn = document.querySelector('[data-camera-target="addPhotoBtn"]')
          if (addBtn) {
            addBtn.classList.remove("hidden")
            this.showDebug("✓ addPhotoBtn shown via DOM query")
          }
        }
        
        this.stopCamera()
        this.showDebug("✓ File processing complete!")
      }
      reader.readAsDataURL(file)
    } else {
      this.showDebug("✗ No file selected")
    }
  }

  async submit() {
    if (this.capturedPhotos.length > 0) {
      await this.submitMultiplePhotos()
    } else {
      await this.submitSinglePhoto()
    }
  }

  async submitSinglePhoto() {
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

  async submitMultiplePhotos() {
    this.loadingTarget.classList.remove("hidden")
    this.submitBtnTarget.disabled = true
    
    try {
      const response = await fetch("/recipes/scan_multiple", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ images: this.capturedPhotos })
      })
      
      const data = await response.json()
      
      if (data.error) {
        alert(data.error)
      } else if (data.redirect_url) {
        window.location.href = data.redirect_url
      }
    } catch (err) {
      console.error("Upload error:", err)
      alert("Failed to process images. Please try again.")
    } finally {
      this.loadingTarget.classList.add("hidden")
      this.submitBtnTarget.disabled = false
    }
  }

  addPhoto() {
    this.capturedPhotos.push(this.previewTarget.src)
    this.updateMultiPhotoPreview()
    this.resetForNewPhoto()
    
    // Hide single photo preview and show multi-photo container
    this.singlePhotoContainerTarget.classList.add("hidden")
  }

  updateMultiPhotoPreview() {
    this.multiPhotoContainerTarget.classList.remove("hidden")
    this.photoPreviewTarget.innerHTML = ""
    
    // Update photo count
    this.photoCountTarget.textContent = this.capturedPhotos.length
    
    this.capturedPhotos.forEach((photo, index) => {
      const photoDiv = document.createElement("div")
      photoDiv.className = "relative group"
      photoDiv.innerHTML = `
        <img src="${photo}" class="w-full h-32 object-cover rounded-lg">
        <button type="button" 
                data-action="click->camera#removePhoto" 
                data-index="${index}"
                class="absolute top-2 right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
          ×
        </button>
        <div class="text-xs text-gray-500 mt-1">Photo ${index + 1}</div>
      `
      this.photoPreviewTarget.appendChild(photoDiv)
    })
    
    this.addPhotoBtnTarget.classList.remove("hidden")
    this.clearPhotosBtnTarget.classList.remove("hidden")
  }

  removePhoto(event) {
    const index = parseInt(event.target.dataset.index)
    this.capturedPhotos.splice(index, 1)
    
    if (this.capturedPhotos.length === 0) {
      this.clearAllPhotos()
    } else {
      this.updateMultiPhotoPreview()
    }
  }

  clearAllPhotos() {
    this.capturedPhotos = []
    this.multiPhotoContainerTarget.classList.add("hidden")
    this.photoPreviewTarget.innerHTML = ""
    this.addPhotoBtnTarget.classList.add("hidden")
    this.clearPhotosBtnTarget.classList.add("hidden")
    this.singlePhotoContainerTarget.classList.add("hidden")
    this.resetForNewPhoto()
  }

  resetForNewPhoto() {
    this.previewTarget.classList.add("hidden")
    this.retakeBtnTarget.classList.add("hidden")
    this.submitBtnTarget.classList.add("hidden")
    this.fileInputTarget.value = ""
    
    // If we have photos, keep add photo button visible
    if (this.capturedPhotos.length > 0) {
      this.addPhotoBtnTarget.classList.remove("hidden")
      this.clearPhotosBtnTarget.classList.remove("hidden")
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
