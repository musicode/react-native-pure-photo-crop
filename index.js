
import { NativeModules } from 'react-native'

const { RNTPhotoCrop } = NativeModules

export default {

  /**
   * Crop an image by url
   *
   * @param {Object} options
   * @property {string} options.url  image url, required
   * @property {number} options.width  crop width, required
   * @property {number} options.height  crop height, required
   * @property {string} options.cancelButtonTitle  optional
   * @property {string} options.resetButtonTitle  optional
   * @property {string} options.submitButtonTitle  optional
   * @return {Promise}
   */
  open(options) {
    return RNTPhotoCrop.open(options)
  },

  /**
   * Compress an image
   *
   * @param {Object} options
   * @property {string} options.path  image original path, required
   * @property {number} options.size  image original size, required
   * @property {number} options.width  image original width, required
   * @property {number} options.height  image original height, required
   *
   * @property {number} options.maxSize  the max size of result you can accepted, required
   * @property {number} options.maxWidth  the max width of result you can accepted, required
   * @property {number} options.maxHeight  the max height of result you can accepted, required
   * @property {number} options.quality  compress quality, 0-1, required
   * @return {Promise}
   */
  compress(options) {
    return RNTPhotoCrop.compress(options)
  }
}
