# Make a presentation

Use this workflow to plan and build a scientific Quarto presentation from this template. Treat the requested presentation folder as the presentation root.

## Orient

Read `README.md`, `AGENTS.md`, `presentation.yml`, and `slide-plan.md`, then learn the surrounding analysis project. Identify its purpose, workflow, compact result objects, data-loading scripts, and candidate figures, images, tables, and explanatory diagrams. Keep local absolute paths, credentials, private URLs, and unpublished personal details out of committed files.

## Agree on the presentation

Discuss the audience, duration, meeting context, purpose, one-sentence story, and HTML output filename. Use `presentation.html` when no name is provided. Update `slide-plan.md` with one message, one primary source of evidence or explanation, one named layout, draft visible text, notes, and status per slide.

Show the proposed overview and wait for explicit approval before expanding `presentation.qmd` or rendering a new presentation. Approval of the plan is the hard gate.

## Build from stable inputs

Use the live learning hub when choosing a layout; in the template repository, `slide-layouts.yml` is the catalogue source. Give each content slide a declarative sentence title, without a closing full stop, and use the matching named class. Prompt + output may instead use an empty heading when the prompt already establishes the purpose. When a figure or image is present, give it most of the slide's content area.

Keep analysis logic in the analysis project or small helpers. Read numbers and figures from `data.summary_file`, named `data.inputs`, or a project data-loading script; never transcribe model results from another presentation.

When no compact summary exists, add project-relative inputs and a focused adapter or refresh helper. Fail clearly when required inputs are missing. Reuse plotting helpers when a figure appears more than once. Keep inline graphics at screen resolution and pre-optimize large external images.

Move detail into speaker notes, preserve scientific meaning and uncertainty, and keep visible text at least 16 pt. Add captions when the analyst wants them; for scientific Prompt + output figures, recommend a short caption when axes and legends leave needed context.

Finish the final slide with the `.credit-note` production line from `AGENTS.md`, and set `project.ai_model` in `presentation.yml` to the concise name of the model you are running as.

## Demonstrate prompts

Use `.prompt-output` by default, adding `.prompt-output-above` or `.prompt-output-floating` when the output needs a different composition. Keep the prompt short and the reply to one first-person sentence describing what was done. Label the reply with the responding model's own concise name via `prompt_reply_label(cfg$project$ai_model)`, falling back to “Agent reply” only when unavailable. Prefer a graphical output that suits the request. Reuse rerenderable results and distinguish any estimated or simulated preview from an executed analysis. A short scientific caption belongs directly below the output; keep detailed methods in notes. For floating bubbles, check data, axes, legends, and captions and change arrangement if no empty region is available.

## Review and deliver

After building, follow the `review-presentation` skill. The presentation is not complete until the rendered path has been visually reviewed.
