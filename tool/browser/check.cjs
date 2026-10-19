// Run against the release build. Test data is created here, never in the app.
const assert = require('node:assert/strict');
const { chromium } = require('playwright');
const base = process.env.EVENTHUB_URL || 'http://127.0.0.1:8080/';
const storageKey = 'gsu-eventhub.events.v1';
const sleep = ms => new Promise(r => setTimeout(r, ms));
async function eventually(check, message) {
  for (let i=0; i<60; i++) { if(await check()) return; await sleep(100); }
  throw Error(message);
}
async function accessible(page) {
  const placeholder=page.locator('flt-semantics-placeholder');
  await eventually(async()=>await placeholder.count() || await page.getByRole('button').count(), 'Flutter did not start');
  if(await placeholder.count()) await placeholder.evaluate(e=>e.click());
}
async function click(page, role, name) {
  const item=page.getByRole(role,{name,exact:true});
  await item.waitFor();
  // Flutter scrolls a canvas; DOM scrollIntoView cannot move its scroll views.
  // Semantics focus requests the Flutter scrollable to reveal the control.
  await item.focus();
  await sleep(150);
  await item.click();
  await sleep(200);
}
async function focusField(page,name) {
 const item=page.getByRole('textbox',{name,exact:true});
 await item.focus();
 // Flutter activates editing after its semantics update, not at DOM focus.
 // The pinned engine applies input configuration when that activation finishes.
 await eventually(()=>item.evaluate(e=>document.activeElement===e && e.getAttribute('autocorrect')==='on'),`Flutter did not activate ${name}`);
 await sleep(200);
 return item;
}
async function fill(page,name,value) {
 const item=await focusField(page,name);
 await item.fill(value);await sleep(200);
 assert.equal(await item.inputValue(),value,`Input did not accept ${name}`);
}
async function fieldValue(page,name) {
 return (await focusField(page,name)).inputValue();
}
async function readEvents(page) {
 return page.evaluate(key=>JSON.parse(localStorage.getItem(key) || '{"events":[]}').events,storageKey);
}
async function route(page,path) {
 await page.goto(`${base}#${path}`);await accessible(page);await sleep(300);
}
(async()=>{
 const browser=await chromium.launch({
   ...(process.env.CHROMIUM_PATH?{executablePath:process.env.CHROMIUM_PATH}:{}),
   args:['--no-sandbox','--enable-unsafe-swiftshader','--use-angle=swiftshader'],
 });
 const context=await browser.newContext({viewport:{width:390,height:844}});
 const page=await context.newPage();
 const errors=[], external=[];
 page.on('pageerror',e=>errors.push(e.message));
 page.on('request',r=>{if(!r.url().startsWith(new URL(base).origin) && /^https?:/.test(r.url()))external.push(r.url());});
 try {
  // A preceding page verifies that Back at the root can leave the application.
  await page.goto(`${base}version.json`);await page.goto(base);await accessible(page);
  await page.goBack();assert.match(page.url(),/version.json/);await page.goForward();await accessible(page);
  await click(page,'button','Open planner');
  await eventually(()=>Promise.resolve(page.url().endsWith('/dashboard')),'Dashboard route missing');
  assert.equal((await readEvents(page)).length,0);
  assert.ok(!(await page.locator('body').innerText()).includes('No account needed'));
  await click(page,'button','Add event');await page.getByRole('textbox',{name:'Title',exact:true}).waitFor();
  assert.match(page.url(),/events\/new/);
  await page.goBack();await eventually(()=>Promise.resolve(page.url().endsWith('/dashboard')),'Back from form failed');
  await page.goForward();await page.getByRole('textbox',{name:'Title',exact:true}).waitFor();
  await fill(page,'Title','Browser test workshop');
  await click(page,'button','Choose date');
  await eventually(()=>Promise.resolve(page.url().includes('/events/new/date')),'Date picker route missing');
  await page.goBack();await page.getByRole('textbox',{name:'Title',exact:true}).waitFor();
  assert.equal(await fieldValue(page,'Title'),'Browser test workshop');
  await page.goForward();await eventually(()=>Promise.resolve(page.url().includes('/events/new/date')),'Forward did not reopen picker');
  await page.goBack();await page.getByRole('textbox',{name:'Title',exact:true}).waitFor();
  await click(page,'button','Choose start time');
  await eventually(()=>Promise.resolve(page.url().includes('/start-time')),'Time picker route missing');
  await page.goBack();await page.getByRole('textbox',{name:'Title',exact:true}).waitFor();
  await fill(page,'Date','2030-05-10');
  await fill(page,'Start time','2:00 PM');await fill(page,'End time','3:30 PM');await fill(page,'Venue','Studio 4');
  await click(page,'button','Save event');
  await page.getByRole('button',{name:'View event',exact:true}).waitFor();
  assert.equal((await readEvents(page))[0].venue,'Studio 4');
  await page.reload();await accessible(page);await page.getByRole('button',{name:'View event',exact:true}).waitFor();
  assert.equal((await readEvents(page)).length,1);
  await click(page,'button','View event');
  await click(page,'button','Edit event');await fill(page,'Title','Edited browser workshop');
  await click(page,'checkbox','Going');await click(page,'button','Save event');
  await page.getByRole('button',{name:'View event',exact:true}).waitFor();
  assert.equal((await readEvents(page))[0].title,'Edited browser workshop');
  assert.equal((await readEvents(page))[0].status,'Going');
  await click(page,'button','View event');await click(page,'button','Delete event');
  await page.getByRole('button',{name:'Keep event',exact:true}).waitFor();
  assert.match(page.url(),/\/delete$/);await page.goBack();
  await page.getByRole('button',{name:'Edit event',exact:true}).waitFor();assert.equal((await readEvents(page)).length,1);
  await page.goForward();await page.getByRole('button',{name:'Keep event',exact:true}).waitFor();
  await click(page,'button','Keep event');await page.getByRole('button',{name:'Edit event',exact:true}).waitFor();
  await route(page,'/events');await fill(page,'Search title or venue','not a match');
  await eventually(async()=>(await page.locator('body').innerText()).includes('No matching events'),'Search did not filter');
  await fill(page,'Search title or venue','studio');
  await click(page,'button','Filters');
  await click(page,'checkbox','Sports');
  await eventually(async()=>(await page.locator('body').innerText()).includes('No matching events'),'Category filter failed');
  await click(page,'checkbox','Seminar');await click(page,'checkbox','Interested');
  await eventually(async()=>(await page.locator('body').innerText()).includes('No matching events'),'Status filter failed');
  await click(page,'checkbox','Going');
  await page.goBack();
  await eventually(()=>Promise.resolve(page.url().endsWith('/events')),'Back did not close filters');
  await eventually(async()=>(await page.locator('body').innerText()).includes('Edited browser workshop'),'Combined filters failed');
  await route(page,'/calendar');await click(page,'checkbox','Week');
  await page.mouse.move(200,430);await page.mouse.wheel(450,350);await sleep(400);
  const noonSlot=()=>page.getByRole('button',{name:/^Add event on .* at 12:00 PM$/}).first();
  const beforeScroll=await noonSlot().boundingBox();
  assert.ok(beforeScroll, 'Calendar slots need accessible labels');
  await click(page,'button','Add event');await page.getByRole('textbox',{name:'Date',exact:true}).waitFor();
  const calendarDate=await fieldValue(page,'Date');
  assert.match(calendarDate,/^\d{4}-\d{2}-\d{2}$/);
  await page.goBack();await page.getByRole('checkbox',{name:'Week',exact:true}).waitFor();
  assert.equal(await page.getByRole('checkbox',{name:'Week',exact:true}).getAttribute('aria-checked'),'true');
  const afterScroll=await noonSlot().boundingBox();
  assert.ok(Math.abs(beforeScroll.x-afterScroll.x)<2 && Math.abs(beforeScroll.y-afterScroll.y)<2, 'Calendar scroll position changed during form navigation');
  await click(page,'button','Add event');await page.getByRole('textbox',{name:'Date',exact:true}).waitFor();
  assert.equal(await fieldValue(page,'Date'),calendarDate);
  await page.goBack();await click(page,'button','Expand timetable');
  await eventually(()=>Promise.resolve(page.url().includes('expanded=1')),'Expanded calendar route failed');
  await page.goBack();await page.getByRole('button',{name:'Calendar',exact:true}).waitFor();
  const eventId=(await readEvents(page))[0].id;
  await route(page,`/events/${eventId}`);await click(page,'button','Delete event');await click(page,'button','Delete');
  await eventually(()=>Promise.resolve(page.url().endsWith('/events')),'Delete did not return to events');
  await page.reload();await accessible(page);assert.equal((await readEvents(page)).length,0);
  // Invalid data recovery is also exercised in the actual browser storage adapter.
  await page.evaluate(key=>localStorage.setItem(key,'invalid JSON'),storageKey);
  await page.reload();await accessible(page);
  await eventually(async()=>(await page.locator('body').innerText()).includes('Saved data could not be read'),'Missing recovery message');
  await page.evaluate(key=>localStorage.removeItem(key),storageKey);
  for (const size of [{width:320,height:640},{width:844,height:390},{width:1440,height:900}]) {
    await page.setViewportSize(size);
    for(const screen of ['/','/dashboard','/events','/calendar','/events/new']) {
      await route(page,screen);
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false,`${screen} horizontal overflow`);
    }
  }
  assert.deepEqual(errors,[],'Browser runtime errors');assert.deepEqual(external,[],'Application requested external resources');
  console.log('PASS: browser root Back, form and picker Back/Forward, draft preservation, save/reload, edit, deletion/cancel/Back/Forward/reload, search/category/status, filter-panel Back, calendar navigation, responsive routes, invalid storage, and bundled resources.');
 } catch(error) {
   console.error(await page.locator('body').ariaSnapshot());
   console.error('URL',page.url());throw error;
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
