import { Controller } from 'stimulus'
import StimulusReflex from 'stimulus_reflex'

/* This is your ApplicationController.
 * All StimulusReflex controllers should inherit from this class.
 *
 * Example:
 *
 *   import ApplicationController from './application_controller'
 *
 *   export default class extends ApplicationController { ... }
 *
 * Learn more at: https://docs.stimulusreflex.com
 */
export default class extends Controller {
  connect () {
    StimulusReflex.register(this)
  }

  /* Application-wide lifecycle methods
   *
   * Use these methods to handle lifecycle concerns for the entire application.
   * Using the lifecycle is optional, so feel free to delete these stubs if you don't need them.
   *
   * Arguments:
   *
   *   element - the element that triggered the reflex
   *             may be different than the Stimulus controller's this.element
   *
   *   reflex - the name of the reflex e.g. "Example#demo"
   *
   *   error/noop - the error message (for reflexError), otherwise null
   *
   *   reflexId - a UUID4 or developer-provided unique identifier for each Reflex
   */

  beforeReflex (element, reflex, noop, reflexId) {
    // document.body.classList.add('wait')
  }

  reflexSuccess (element, reflex, noop, reflexId) {
    // show success message etc...
  }

  reflexError (element, reflex, error, reflexId) {
    // show error message etc...
  }

  afterReflex (element, reflex, noop, reflexId) {
    // document.body.classList.remove('wait')
  }

  const navSlide = () => {
    const mobile-nav = document.querySelector('.mobile-nav');
    const nav = document.querySelector('.nav-links');
    const navLinks = document.querySelectorAll('.nav-links li');

    //Toggle navbar
    mobile-nav.addEventListener('Click', ()=>{
      nav.classList.toggle('nav-active');

      //link animation
      navLinks.forEach((link, index)=>{
        if(link.style.animation){
          link.style.animation = ''
        } else {
          link.style.animation = `navLinkFade 0.6s ease forwards ${index / 7 + 0.5}s`;
        }
      });
      // Icon animation
      mobile-nav.classList.toggle('toggle');
    });

  }

  navSlide();

}
