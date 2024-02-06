import Service from '@ember/service';
import { dropTask, timeout } from 'ember-concurrency';
import type { Task } from 'ember-concurrency';

type RequestGitHubRateLimitTask = Task<number, []>;

export default class ApiService extends Service {
  async requestGitHubRateLimit (): Promise<number> {
    const resultRaw = await fetch('https://api.github.com/rate_limit', {
      method: 'GET',
      headers: {
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    });

    const result = await resultRaw.json();

    // Validation
    if (typeof result.rate.limit !== 'number') {
      throw new Error('Invalid payload. :(');
    }

    return result.rate.limit;
  }

  requestGitHubRateLimitTask = dropTask(async () => {
    return await this.requestGitHubRateLimit();
  });
}
