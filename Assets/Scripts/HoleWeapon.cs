using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class HoleWeapon : MonoBehaviour
{
    [SerializeField] private GroundShaderController gsc;
    [SerializeField] private Camera camera;
    [SerializeField] private LineRenderer lineRenderer;
    [SerializeField] private Vector3 lineOffset;

    private void OnValidate()
    {
        lineRenderer = GetComponent<LineRenderer>();
        camera = GetComponentInChildren<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit;
        Ray ray = camera.ScreenPointToRay(Input.mousePosition);
        lineRenderer.SetPosition(0, camera.transform.position + transform.TransformDirection(lineOffset));
        if (Physics.Raycast(ray, out hit))
        {
            lineRenderer.SetPosition(1, hit.point);

            if (Input.GetMouseButtonDown(0))
            {
                gsc.MakeHole(-hit.textureCoord + (Vector2.one / 2));
            }
        } 
        else
        {
            lineRenderer.SetPosition(1, camera.transform.position);
        }
    }
}
