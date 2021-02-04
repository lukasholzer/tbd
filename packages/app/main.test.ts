import {moduleB} from '@tbd/module-b';

it('hello world', () => {
  expect(moduleB()).toBe('My-module-b');
  expect(moduleB()).toMatchInlineSnapshot(`"My-module-b"`);
});
