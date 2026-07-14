/**
 * pi-taskwarrior — pi extension providing TaskWarrior CRUD tools.
 *
 * Registers 9 tools: task_add, task_list, task_show, task_check,
 * task_modify, task_start, task_stop, task_done, task_delete.
 *
 * All tools operate on UUIDs, never integer IDs. TaskWarrior hooks
 * (on-add, on-modify) fire transparently when `task` CLI is called.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerTaskAdd } from "./tools/task-add";
import { registerTaskCheck } from "./tools/task-check";
import { registerTaskDelete } from "./tools/task-delete";
import { registerTaskDone } from "./tools/task-done";
import { registerTaskList } from "./tools/task-list";
import { registerTaskModify } from "./tools/task-modify";
import { registerTaskShow } from "./tools/task-show";
import { registerTaskStart } from "./tools/task-start";
import { registerTaskStop } from "./tools/task-stop";

export default function (pi: ExtensionAPI) {
  // Verify taskwarrior is available at startup
  pi.on("session_start", async (_event, ctx) => {
    const check = await pi.exec("task", ["--version"], { timeout: 5000 });
    if (check.code !== 0) {
      ctx.ui.notify(
        "pi-taskwarrior: task executable not found. Tools will fail.",
        "warning",
      );
    }
  });

  registerTaskAdd(pi);
  registerTaskList(pi);
  registerTaskShow(pi);
  registerTaskModify(pi);
  registerTaskStart(pi);
  registerTaskStop(pi);
  registerTaskDone(pi);
  registerTaskCheck(pi);
  registerTaskDelete(pi);
}
