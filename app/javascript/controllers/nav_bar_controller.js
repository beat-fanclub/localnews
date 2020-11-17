import { Controller } from "stimulus"

export default class extends ApplicationController {

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
