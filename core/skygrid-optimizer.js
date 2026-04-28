#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const fixturePath = path.resolve(process.cwd(), 'tests/fixtures/skygrid-events.mock.json');
const outputPath = path.resolve(process.cwd(), 'tests/fixtures/skygrid-events.optimized.json');

function toMinutes(dateString) {
  return Math.floor(new Date(dateString).getTime() / 60000);
}

function optimize(events) {
  const sorted = [...events].sort((a, b) => {
    if (a.priority !== b.priority) {
      return b.priority - a.priority;
    }

    return toMinutes(a.startsAt) - toMinutes(b.startsAt);
  });

  const accepted = [];

  for (const event of sorted) {
    const eventStart = toMinutes(event.startsAt);
    const eventEnd = eventStart + event.durationMinutes;

    const overlaps = accepted.some((acceptedEvent) => {
      const acceptedStart = toMinutes(acceptedEvent.startsAt);
      const acceptedEnd = acceptedStart + acceptedEvent.durationMinutes;
      return eventStart < acceptedEnd && acceptedStart < eventEnd;
    });

    if (!overlaps) {
      accepted.push(event);
    }
  }

  return accepted.sort((a, b) => toMinutes(a.startsAt) - toMinutes(b.startsAt));
}

function main() {
  const fixture = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));
  const optimizedEvents = optimize(fixture.events || []);

  const output = {
    source: 'tests/fixtures/skygrid-events.mock.json',
    generatedAt: new Date().toISOString(),
    originalCount: fixture.events?.length || 0,
    optimizedCount: optimizedEvents.length,
    droppedCount: (fixture.events?.length || 0) - optimizedEvents.length,
    events: optimizedEvents,
  };

  fs.writeFileSync(outputPath, JSON.stringify(output, null, 2) + '\n');

  console.log(`Optimized ${output.originalCount} events -> ${output.optimizedCount}.`);
  console.log(`Output: ${path.relative(process.cwd(), outputPath)}`);
}

main();
