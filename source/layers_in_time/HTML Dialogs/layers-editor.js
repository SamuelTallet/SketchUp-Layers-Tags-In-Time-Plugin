/**
 * Layers/Tags In Time extension for SketchUp.
 *
 * @copyright © 2021 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * Layers/Tags In Time plugin namespace.
 */
LayersInTime = {}

/**
 * Regular expression for validating layer dates.
 * 
 * Note: Because all years aren't leap years, time layers don't support leap
 * years. This explains why February 29 isn't a valid date for a time layer.
 * 
 * @type {RegExp}
 */
LayersInTime.LAYER_DATES_REGEX = /^((((0[1-9]|1[0-2])\/([01][1-9]|10|2[0-8]))|((0[13-9]|1[0-2])\/(29|30))|((0[13578]|1[02])\/31)) - (((0[1-9]|1[0-2])\/([01][1-9]|10|2[0-8]))|((0[13-9]|1[0-2])\/(29|30))|((0[13578]|1[02])\/31)))$/

/**
 * Layer dates mask's placeholder value.
 * 
 * @type {string}
 */
LayersInTime.LAYER_DATES_PLACEHOLDER = '__/__ - __/__'

/**
 * Regular expression for validating layer hours.
 * 
 * @type {RegExp}
 */
LayersInTime.LAYER_HOURS_REGEX = /^((([0-1][0-9]|2[0-3]):([0-5][0-9])) - (([0-1][0-9]|2[0-3]):([0-5][0-9])))$/

/**
 * Layer hours mask's placeholder value.
 * 
 * @type {string}
 */
LayersInTime.LAYER_HOURS_PLACEHOLDER = '__:__ - __:__'

/**
 * Clipboard storing time data.
 * 
 * @type {object}
 */
LayersInTime.clipboard = {}

/**
 * Gets layer dates input field.
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {HTMLInputElement}
 */
LayersInTime.getLayerDatesInputField = (layerObjectId) => {

    let layer = document.querySelector('.layer[data-layer-object-id="' + layerObjectId + '"]')

    return layer.querySelector('.dates.input-field')

}

/**
 * Is this layer a dates layer?
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {boolean}
 */
LayersInTime.isDatesLayer = (layerObjectId) => {

    let layerDatesInputField = LayersInTime.getLayerDatesInputField(layerObjectId)

    return layerDatesInputField.value !== LayersInTime.LAYER_DATES_PLACEHOLDER

}

/**
 * Validates dates input field value of a given layer.
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {boolean} true if field is valid else false.
 */
LayersInTime.validateLayerDates = (layerObjectId) => {

    let layerDatesInputField = LayersInTime.getLayerDatesInputField(layerObjectId)

    if (
        layerDatesInputField.value == LayersInTime.LAYER_DATES_PLACEHOLDER ||
        LayersInTime.LAYER_DATES_REGEX.test(layerDatesInputField.value)
       )
    {

        layerDatesInputField.classList.remove('invalid')
        return true

    } else {

        layerDatesInputField.classList.add('invalid')
        return false

    }

}

/**
 * Clears dates input field value of a given layer.
 * 
 * @param {string|number} layerObjectId 
 */
LayersInTime.clearLayerDates = (layerObjectId) => {

    let layerDatesInputField = LayersInTime.getLayerDatesInputField(layerObjectId)
    layerDatesInputField.value = ''
    layerDatesInputField.dispatchEvent(new Event('blur')) // Update mask and validate value.

}

/**
 * Gets layer hours input field.
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {HTMLInputElement}
 */
LayersInTime.getLayerHoursInputField = (layerObjectId) => {

    let layer = document.querySelector('.layer[data-layer-object-id="' + layerObjectId + '"]')

    return layer.querySelector('.hours.input-field')

}

/**
 * Is this layer a hours layer?
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {boolean}
 */
LayersInTime.isHoursLayer = (layerObjectId) => {

    let layerHoursInputField = LayersInTime.getLayerHoursInputField(layerObjectId)

    return layerHoursInputField.value !== LayersInTime.LAYER_HOURS_PLACEHOLDER

}

/**
 * Validates hours input field value of a given layer.
 * 
 * @param {string|number} layerObjectId
 *
 * @returns {boolean} true if field is valid else false.
 */
LayersInTime.validateLayerHours = (layerObjectId) => {

    let layerHoursInputField = LayersInTime.getLayerHoursInputField(layerObjectId)

    if (
        layerHoursInputField.value == LayersInTime.LAYER_HOURS_PLACEHOLDER ||
        LayersInTime.LAYER_HOURS_REGEX.test(layerHoursInputField.value)
       )
    {

        layerHoursInputField.classList.remove('invalid')
        return true

    } else {

        layerHoursInputField.classList.add('invalid')
        return false

    }

}

/**
 * Clears hours input field value of a given layer.
 * 
 * @param {string|number} layerObjectId 
 */
LayersInTime.clearLayerHours = (layerObjectId) => {

    let layerHoursInputField = LayersInTime.getLayerHoursInputField(layerObjectId)
    layerHoursInputField.value = ''
    layerHoursInputField.dispatchEvent(new Event('blur')) // Update mask and validate value.

}

/**
 * Is this layer a time layer?
 * 
 * @param {string|number} layerObjectId
 * 
 * @returns {boolean}
 */
LayersInTime.isTimeLayer = (layerObjectId) => {

    return LayersInTime.isDatesLayer(layerObjectId) || LayersInTime.isHoursLayer(layerObjectId)

}

/**
 * Hides copy buttons of all layers.
 */
LayersInTime.hideLayersCopyButtons = () => {

    document.querySelectorAll('.layer .copy.button').forEach(layerCopyButton => {
        layerCopyButton.classList.add('hidden')
    })

}

/**
 * Displays copy buttons of all layers.
 */
LayersInTime.displayLayersCopyButtons = () => {

    document.querySelectorAll('.layer .copy.button').forEach(layerCopyButton => {
        layerCopyButton.classList.remove('hidden')
    })

}

/**
 * Copies into clipboard time data of a given layer.
 * 
 * @param {string|number} layerObjectId 
 */
LayersInTime.copyTimeData = (layerObjectId) => {

    LayersInTime.clipboard = {

        dates: LayersInTime.getLayerDatesInputField(layerObjectId).value,
        hours: LayersInTime.getLayerHoursInputField(layerObjectId).value

    }

}

/**
 * Hides paste buttons of all layers.
 */
LayersInTime.hideLayersPasteButtons = () => {

    document.querySelectorAll('.layer .paste.button').forEach(layerPasteButton => {
        layerPasteButton.classList.add('hidden')
    })

}

/**
 * Displays paste buttons of all layers.
 */
LayersInTime.displayLayersPasteButtons = () => {

    document.querySelectorAll('.layer .paste.button').forEach(layerPasteButton => {
        layerPasteButton.classList.remove('hidden')
    })

}

/**
 * Paste time data stored in clipboard to a layer.
 * 
 * @param {string|number} layerObjectId 
 */
LayersInTime.pasteTimeData = (layerObjectId) => {

    let layerDatesInputField = LayersInTime.getLayerDatesInputField(layerObjectId)
    let layerHoursInputField = LayersInTime.getLayerHoursInputField(layerObjectId)

    layerDatesInputField.value = LayersInTime.clipboard.dates
    layerDatesInputField.dispatchEvent(new Event('keyup')) // Display or hide clear button.

    layerHoursInputField.value = LayersInTime.clipboard.hours
    layerHoursInputField.dispatchEvent(new Event('keyup')) // Display or hide clear button.

}

/**
 * Displays or hides clear time data button of a given layer.
 * 
 * @param {string|number} layerObjectId 
 */
LayersInTime.displayOrHideLayerClearButton = (layerObjectId) => {

    let layer = document.querySelector('.layer[data-layer-object-id="' + layerObjectId + '"]')
    let layerClearButton = layer.querySelector('.clear.button')

    if ( LayersInTime.isTimeLayer(layerObjectId) ) {
        layerClearButton.classList.remove('hidden')
    } else {
        layerClearButton.classList.add('hidden')
    }

}

/**
 * Validates then updates layers time data.
 */
LayersInTime.validateUpdateLayers = () => {

    let layers = document.querySelectorAll('.layer')
    let layersTimeData = {}
    let hasInvalidLayers = false

    layers.forEach(layer => {

        let layerObjectId = layer.dataset.layerObjectId

        if (
            !LayersInTime.validateLayerDates(layerObjectId) ||
            !LayersInTime.validateLayerHours(layerObjectId)
           )
        {
            hasInvalidLayers = true
        }
        
    })

    if ( !hasInvalidLayers ) {

        layers.forEach(layer => {

            let layerObjectId = layer.dataset.layerObjectId
    
            layersTimeData[layerObjectId] = {
                dates: LayersInTime.getLayerDatesInputField(layerObjectId).value,
                hours: LayersInTime.getLayerHoursInputField(layerObjectId).value
            }
            
        })

        sketchup.updateLayers(layersTimeData)

    } else {
        window.alert(document.querySelector('.invalid-time-data-error-message').innerHTML)
    }

}

/**
 * Masks layers time data input fields.
 */
LayersInTime.maskInputFields = () => {

    document.querySelectorAll('.layer .dates.input-field').forEach(layerDatesInputField => {

        IMask(layerDatesInputField, {
            mask: 'm/d - m/d',
            blocks: {
                // Month
                m: {
                  mask: IMask.MaskedRange,
                  from: 1,
                  to: 12
                },
                // Day
                d: {
                    mask: IMask.MaskedRange,
                    from: 1,
                    to: 31
                }
            },
            lazy: false
        })

    })

    document.querySelectorAll('.layer .hours.input-field').forEach(layerHoursInputField => {

        IMask(layerHoursInputField, {
            mask: 'h:m - h:m',
            blocks: {
                // Hour
                h: {
                    mask: IMask.MaskedRange,
                    from: 0,
                    to: 23
                },
                // Minute
                m: {
                  mask: IMask.MaskedRange,
                  from: 0,
                  to: 59
                }
            },
            lazy: false
        })

    })

}

/**
 * Makes layers sortable by name, etc.
 */
LayersInTime.makeLayersSortable = () => {
      
    new List('layers', {
        valueNames: ['name', 'start-date', 'end-date', 'start-hour', 'end-hour']
    })

}

/**
 * Sorts layers by...
 * 
 * @param {string} sortField
 */
LayersInTime.sortLayersBy = (sortField) => {

    if ( sortField !== '' ) {
        document.querySelector('.sort.button[data-sort="' + sortField + '"]').click()
    }

}

/**
 * Restores layers sort.
 */
LayersInTime.restoreLayersSort = () => {

    let sortDropdown = document.querySelector('.sort.dropdown')

    sortDropdown.value = sortDropdown.dataset.sessionSort

    LayersInTime.sortLayersBy(sortDropdown.dataset.sessionSort)

}

/**
 * Adds event listeners.
 */
LayersInTime.addEventListeners = () => {

    document.querySelector('.sort.dropdown').addEventListener('change', event => {

        LayersInTime.sortLayersBy(event.currentTarget.value)
        sketchup.retainLayersSort(event.currentTarget.value)

    })

    document.querySelectorAll('.layer .dates.input-field').forEach(layerDatesInputField => {

        // Layer dates and hours are mutually exclusive.
        layerDatesInputField.addEventListener('input', event => {
            LayersInTime.clearLayerHours(event.currentTarget.dataset.layerObjectId)
        })

        layerDatesInputField.addEventListener('keyup', event => {
            LayersInTime.displayOrHideLayerClearButton(event.currentTarget.dataset.layerObjectId)
        })

        layerDatesInputField.dispatchEvent(new Event('keyup'))

        layerDatesInputField.addEventListener('blur', event => {
            LayersInTime.validateLayerDates(event.currentTarget.dataset.layerObjectId)
        })

    })

    document.querySelectorAll('.layer .hours.input-field').forEach(layerHoursInputField => {

        // Layer hours and dates are mutually exclusive.
        layerHoursInputField.addEventListener('input', event => {
            LayersInTime.clearLayerDates(event.currentTarget.dataset.layerObjectId)
        })

        layerHoursInputField.addEventListener('keyup', event => {
            LayersInTime.displayOrHideLayerClearButton(event.currentTarget.dataset.layerObjectId)
        })

        layerHoursInputField.dispatchEvent(new Event('keyup'))

        layerHoursInputField.addEventListener('blur', event => {
            LayersInTime.validateLayerHours(event.currentTarget.dataset.layerObjectId)
        })

    })

    document.querySelectorAll('.layer .copy.button').forEach(layerCopyButton => {

        layerCopyButton.addEventListener('click', event => {

            LayersInTime.hideLayersCopyButtons()

            LayersInTime.copyTimeData(event.currentTarget.dataset.layerObjectId)

            LayersInTime.displayLayersPasteButtons()
            
        })

    })

    document.querySelectorAll('.layer .paste.button').forEach(layerPasteButton => {

        layerPasteButton.addEventListener('click', event => {

            LayersInTime.hideLayersPasteButtons()

            LayersInTime.pasteTimeData(event.currentTarget.dataset.layerObjectId)

            LayersInTime.displayLayersCopyButtons()
            
        })

    })
    
    document.querySelectorAll('.layer .clear.button').forEach(layerClearButton => {

        layerClearButton.addEventListener('click', event => {

            LayersInTime.clearLayerDates(event.currentTarget.dataset.layerObjectId)
            LayersInTime.clearLayerHours(event.currentTarget.dataset.layerObjectId)

            event.currentTarget.classList.add('hidden')

        })

    })

    document.querySelector('.save-changes.button').addEventListener('click', _event => {
        LayersInTime.validateUpdateLayers()
    })

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

    if ( document.querySelectorAll('.layer').length >= 1 ) {

        LayersInTime.maskInputFields()
        LayersInTime.makeLayersSortable()
        LayersInTime.restoreLayersSort()
        LayersInTime.addEventListeners()

    }

})
