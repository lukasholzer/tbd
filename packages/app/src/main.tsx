import {Fragment, h, render} from 'preact';
import {App} from './app/app';

import './styles.css';

const el = document.getElementById('app');

if (el) {
  render(<App />, el);
}
