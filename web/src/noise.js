class NoiseGenerator extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [{name: 'amplitude', defaultValue: 0.25, minValue: 0, maxValue: 1}];
  }

  constructor(options) {
    super();
    console.log(options.processorOptions);

    this.samplesToRequest = 48000; // NOTE: This should be a factor of 128 - otherwise we will get gliches
    this.buf1 = new Float32Array(this.samplesToRequest);
    this.buf2 = new Float32Array(this.samplesToRequest);
    this.consumeBuf = this.buf1;
    this.index = 0;

    // Receive audio samples
    this.port.onmessage = (e) => {
        // Update the buffer that is not being consumed
        if (this.consumeBuf == this.buf1) {
            this.buf2 = e.data;
            // console.log("buf2 updated");
        } else {
            this.buf1 = e.data;
            // console.log("buf1 updated");
        }
    }

    if (options.processorOptions) {
        //
    }
  }
  process(inputs, outputs, parameters) {
    const output = outputs[0];

    for (let channel = 0; channel < output.length; ++channel) {
      const outputChannel = output[channel];
      for (let i = 0; i < outputChannel.length; ++i) {
        // Example to generate noise
        // outputChannel[i] = 2 * (Math.random() - 0.5);

        outputChannel[i] = this.consumeBuf[this.index];
        this.index = (this.index + 1) % this.consumeBuf.length;
      }
    }

    if (this.index == 0) {
        // Flip active buffers
        if (this.consumeBuf == this.buf1) {
            this.consumeBuf = this.buf2;
            // console.log("consumeBuf = buf2");
        } else {
            this.consumeBuf = this.buf1;
            // console.log("consumeBuf = buf1");
        }
        this.requested = false;
    }

    // Request a new buffer when we have consumed half of the current buffer
    if (this.index > this.consumeBuf.length / 2 && !this.requested) {
        const samples = this.samplesToRequest;
        this.requested = true;
        this.port.postMessage(samples);
        // console.log(`Request ${samples}`);        
    }

    return true;
  }
}

registerProcessor('noise-generator', NoiseGenerator);