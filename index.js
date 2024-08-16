
import { NativeModules } from 'react-native'

const { RNTPhotoCrop } = NativeModules

export default {

  /**
   * Crop an image by url
   *
   * @param {Object} options
   * @property {string} options.url  image url, required
   * @property {number} options.width  crop width, required
   * @property {number} options.height crop height, required
   * @property {string} options.guideLabelTitle optional
   * @property {string} options.cancelButtonTitle  optional
   * @property {string} options.resetButtonTitle  optional
   * @property {string} options.submitButtonTitle  optional
   * @return {Promise}
   */
  open(options) {
    return RNTPhotoCrop.open(options)
  },

}
