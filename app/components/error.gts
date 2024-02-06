import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import type ApiService from 'ember-app-concurrency-demo/services/api';
import { on } from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';
import { task, timeout } from 'ember-concurrency';
import { tracked } from '@glimmer/tracking';

export default class ErrorComponent extends Component {
  @service api!: ApiService;

  @tracked shouldError = false;

  requestAndMaybeErrorTask = task(async () => {
    const result = await this.api.requestGitHubRateLimit();

    if (this.shouldError) {
      throw new Error('Something wrong happened');
    }

    return result;
  });

  updateShouldError = (event: InputEvent) => {
    console.log((event.target as HTMLInputElement).checked);
    this.shouldError = (event.target as HTMLInputElement).checked;
  };

  <template>
    <div
      style="
        border: 2px solid black;
        padding: 2em;
      "
      ...attributes
    >
      <p>
        <label>
          <input
            type="checkbox"
            checked={{this.shouldError}}
            {{on 'change' this.updateShouldError}}
          >

          Should error
        </label>
      </p>

      <p>
        <button
          type="button"
          {{on "click" (perform this.requestAndMaybeErrorTask)}}
        >
          Request GitHub rate limit
        </button>
      </p>

      <p>
        {{#if this.requestAndMaybeErrorTask.lastSuccessful}}
          Rate limit: {{this.requestAndMaybeErrorTask.lastSuccessful.value}}
        {{/if}}

        {{#if this.requestAndMaybeErrorTask.isRunning}}
          Updating...
        {{else if this.requestAndMaybeErrorTask.last.error}}
          {{! ToDo: implement error parsing}}
          Error: {{this.requestAndMaybeErrorTask.last.error}}
        {{else if this.requestAndMaybeErrorTask.isIdle}}
          Idle
        {{else}}
          This should be unreachable
        {{/if}}
      </p>
    </div>
  </template>
}