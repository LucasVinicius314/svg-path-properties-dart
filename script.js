'use strict'

const targetSteps = 10 - 1

const svg = document.getElementsByTagName('svg')[0]

const paths = [...document.getElementsByTagName('path')]

const svgBounds = {
  top: Infinity,
  left: Infinity,
  right: -Infinity,
  bottom: -Infinity,
}

for (const path of paths) {
  const length = path.getTotalLength()

  const step = length / targetSteps

  console.log({ length, step })

  const pathBounds = {
    top: Infinity,
    left: Infinity,
    right: -Infinity,
    bottom: -Infinity,
  }

  for (let index = 0; index <= targetSteps; index++) {
    const position = index * step

    const point = path.getPointAtLength(position)

    if (point.y < pathBounds.top) {
      pathBounds.top = point.y
    }

    if (point.x < pathBounds.left) {
      pathBounds.left = point.x
    }

    if (point.x > pathBounds.right) {
      pathBounds.right = point.x
    }

    if (point.y > pathBounds.bottom) {
      pathBounds.bottom = point.y
    }

    console.log({ index, point, position })

    const newCircle = document.createElementNS(
      'http://www.w3.org/2000/svg',
      'circle'
    )

    newCircle.setAttribute('cx', point.x.toFixed(0))
    newCircle.setAttribute('cy', point.y.toFixed(0))
    newCircle.setAttribute('r', (3).toFixed(0))

    newCircle.setAttribute('fill', 'blue')

    svg.appendChild(newCircle)
  }

  console.log(pathBounds)

  const newPath = document.createElementNS('http://www.w3.org/2000/svg', 'path')

  newPath.setAttribute(
    'd',
    `M${pathBounds.left.toFixed(0)} ${pathBounds.top.toFixed(
      0
    )} L${pathBounds.right.toFixed(0)} ${pathBounds.top.toFixed(
      0
    )} L${pathBounds.right.toFixed(0)} ${pathBounds.bottom.toFixed(
      0
    )} L${pathBounds.left.toFixed(0)} ${pathBounds.bottom.toFixed(
      0
    )} L${pathBounds.left.toFixed(0)} ${pathBounds.top.toFixed(0)} Z`
  )

  newPath.setAttribute('fill', 'none')
  newPath.setAttribute('stroke', 'red')

  svg.appendChild(newPath)

  if (pathBounds.top < svgBounds.top) {
    svgBounds.top = pathBounds.top
  }

  if (pathBounds.left < svgBounds.left) {
    svgBounds.left = pathBounds.left
  }

  if (pathBounds.right > svgBounds.right) {
    svgBounds.right = pathBounds.right
  }

  if (pathBounds.bottom > svgBounds.bottom) {
    svgBounds.bottom = pathBounds.bottom
  }
}

const newPath = document.createElementNS('http://www.w3.org/2000/svg', 'path')

newPath.setAttribute(
  'd',
  `M${svgBounds.left.toFixed(0)} ${svgBounds.top.toFixed(
    0
  )} L${svgBounds.right.toFixed(0)} ${svgBounds.top.toFixed(
    0
  )} L${svgBounds.right.toFixed(0)} ${svgBounds.bottom.toFixed(
    0
  )} L${svgBounds.left.toFixed(0)} ${svgBounds.bottom.toFixed(
    0
  )} L${svgBounds.left.toFixed(0)} ${svgBounds.top.toFixed(0)} Z`
)

newPath.setAttribute('fill', 'none')
newPath.setAttribute('stroke', '#33FF335F')

svg.appendChild(newPath)

svg.style.backgroundColor = 'lightgrey'

/** @type {{ x: 0, y: 0 }[]} */
let strokePoints = []

/** @type {{ x: 0, y: 0 }[]} */
let lerpedStrokePoints = []

/** @type {SVGCircleElement[]} */
let strokeElements = []

/** @type {SVGCircleElement[]} */
let lerpedStrokeElements = []

let timeoutId = 0

let pointerCoordinates = {
  x: 0,
  y: 0,
}

svg.addEventListener('mousemove', (e) => {
  pointerCoordinates = {
    x: e.x,
    y: e.y,
  }
})

svg.addEventListener('mousedown', () => {
  strokePoints = []
  lerpedStrokePoints = []

  for (const strokeElement of strokeElements) {
    strokeElement.remove()
  }

  strokeElements = []

  for (const lerpedStrokeElement of lerpedStrokeElements) {
    lerpedStrokeElement.remove()
  }

  lerpedStrokeElements = []

  timeoutId = setInterval(() => {
    strokePoints.push({ ...pointerCoordinates })
  }, 1000 / 30)
})

svg.addEventListener('mouseup', () => {
  clearInterval(timeoutId)

  for (const strokePoint of strokePoints) {
    const newCircle = document.createElementNS(
      'http://www.w3.org/2000/svg',
      'circle'
    )

    newCircle.setAttribute('cx', strokePoint.x.toFixed(0))
    newCircle.setAttribute('cy', strokePoint.y.toFixed(0))
    newCircle.setAttribute('r', (0.5).toFixed(1))

    newCircle.setAttribute('fill', 'magenta')

    svg.appendChild(newCircle)

    strokeElements.push(newCircle)
  }

  const indexStep = strokePoints.length / targetSteps

  console.log({ indexStep, strokePointsLength: strokePoints.length })

  for (let index = 0; index <= targetSteps; index++) {
    const targetIndex = index * indexStep

    const fraction = targetIndex % 1

    const wholeFloor = targetIndex - fraction

    console.log({ wholeFloor, fraction })

    if (fraction === 0) {
      console.log('pushing whole')
      lerpedStrokePoints.push({ ...strokePoints[wholeFloor] })
    } else {
      const a = strokePoints[wholeFloor]
      const b = strokePoints[wholeFloor + 1]

      lerpedStrokePoints.push({
        x: a.x + (b.x - a.x) * fraction,
        y: a.y + (b.y - a.y) * fraction,
      })
    }
  }

  console.log(lerpedStrokePoints)

  for (const lerpedStrokePoint of lerpedStrokePoints) {
    const newCircle = document.createElementNS(
      'http://www.w3.org/2000/svg',
      'circle'
    )

    newCircle.setAttribute('cx', lerpedStrokePoint.x.toFixed(0))
    newCircle.setAttribute('cy', lerpedStrokePoint.y.toFixed(0))
    newCircle.setAttribute('r', (1).toFixed(0))

    newCircle.setAttribute('fill', 'orange')

    svg.appendChild(newCircle)

    lerpedStrokeElements.push(newCircle)
  }
})
