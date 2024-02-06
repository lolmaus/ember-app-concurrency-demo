import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import type ApiService from 'ember-app-concurrency-demo/services/api';
import { on } from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';
import { task, timeout } from 'ember-concurrency';

export default class CancellationComponent extends Component {
  @service api!: ApiService;

  requestWithDelayAndAlertTask = task(async () => {
    const result = await this.api.requestGitHubRateLimit();

    await timeout(3000);

    alert(result);

    return result;
  });

  cancelRequestWithDelayAndAlert = () => {
    this.requestWithDelayAndAlertTask.cancelAll();
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
        <button
          type="button"
          {{on "click" (perform this.requestWithDelayAndAlertTask)}}
        >
          Request GitHub rate limit, wait 3 seconds and alert
        </button>
      </p>

      <p>
        {{#if this.requestWithDelayAndAlertTask.lastSuccessful}}
          Rate limit: {{this.requestWithDelayAndAlertTask.lastSuccessful.value}}
        {{/if}}

        {{#if this.requestWithDelayAndAlertTask.isRunning}}
          Updating...
        {{else if this.requestWithDelayAndAlertTask.last.error}}
          {{! ToDo: implement error parsing}}
          Error: {{this.requestWithDelayAndAlertTask.last.error}}
        {{else if this.api.requestGitHubRateLimitTask.isIdle}}
          Idle
        {{else}}
          This should be unreachable
        {{/if}}
      </p>

      {{#if this.requestWithDelayAndAlertTask.isRunning}}
        <button
          type="button"
          {{on "click" this.cancelRequestWithDelayAndAlert}}
        >
          Cancel
        </button>
      {{/if}}
    </div>
  </template>
}