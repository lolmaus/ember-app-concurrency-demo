import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';
import { task, timeout } from 'ember-concurrency';
import { tracked } from '@glimmer/tracking';

export default class ChildComponent extends Component {
  childComponentTask = task(async () => {
    const result = await this.args.parentComponentTask.perform()
    return `child component's task return value concatenated with ${result}`;
  });

  cancelParentTaskAction = () => {
    this.childComponentTask.cancelAll();
  };

  <template>
    <div
      style="
        border: 2px solid black;
        padding: 2em;
      "
      ...attributes
    >
      <h2>Child comopnent</h2>

      <p>
        <button
          type="button"
          disabled={{this.api.childComponentTask.isRunning}}
          {{on "click" (perform this.childComponentTask)}}
        >
          Run child component's task
        </button>
        
        (which in turn runs the parent's task)
      </p>

      {{#if this.childComponentTask.lastSuccessful}}
        <p>
          Child component's task result:
          <br>
          {{this.childComponentTask.lastSuccessful.value}}
        </p>
      {{/if}}

      {{#if this.childComponentTask.isRunning}}
        <p>Updating parent task...</p>
      {{else if this.childComponentTask.last.error}}
        {{! ToDo: implement error parsing}}
        <p>Child component's task error: {{this.childComponentTask.last.error}}</p>
      {{else if this.childComponentTask.isIdle}}
        <p>Child component's task idle</p>
      {{else}}
        This should be unreachable
      {{/if}}

      {{#if this.childComponentTask.isRunning}}
        <p>
          <button
            type="button"
            {{on "click" this.cancelParentTaskAction}}
          >
            Cancel the child component's task
          </button>
        </p>
      {{/if}}
    </div>
  </template>
}