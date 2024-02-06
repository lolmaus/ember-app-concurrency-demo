import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';
import { task, timeout } from 'ember-concurrency';
import { tracked } from '@glimmer/tracking';
import Child from './child';

export default class ParentComponent extends Component {
  parentComponentTask = task(async () => {
    await timeout(3000);
    return "parent component's task return value";
  });

  <template>
    <div
      style="
        border: 2px solid black;
        padding: 2em;
      "
      ...attributes
    >
      <h2>Parent comopnent</h2>

      <hr>

      {{#if this.parentComponentTask.lastSuccessful}}
        <p>
          Parent component's task result:
          <br>
          {{this.parentComponentTask.lastSuccessful.value}}
        </p>
      {{/if}}

      {{#if this.parentComponentTask.isRunning}}
        <p>Updating parent component's task...</p>
      {{else if this.parentComponentTask.last.error}}
        {{! ToDo: implement error parsing}}
        <p>Parent component's task error: {{this.parentComponentTask.last.error}}</p>
      {{else if this.parentComponentTask.isIdle}}
        <p>Parent component's task idle</p>
      {{else}}
        This should be unreachable
      {{/if}}

      <Child @parentComponentTask={{this.parentComponentTask}} />
    </div>
  </template>
}